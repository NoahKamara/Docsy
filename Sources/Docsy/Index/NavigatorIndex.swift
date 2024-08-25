//
//  File.swift
//  Docsy
//
//  Created by Noah Kamara on 25.08.24.
//

import Foundation
import OSLog


@Observable
public class NavigatorIndex {
    static let logger = Logger.docsy("Index")

    public let identifier: BundleIdentifier
    public let context: DocumentationContext

    private var index: DocumentationIndex?

    public var hasLoaded: Bool {
        access(keyPath: \.index)
        return index != nil
    }

    public init(identifier: BundleIdentifier, context: DocumentationContext) {
        self.identifier = identifier
        self.context = context
        self.root = RootNode(bundleIdentifier: identifier)
    }

    /// A mapping of interface languages to the index nodes they contain.
    public var root: RootNode

    /// The values of the image references used in the documentation index.
    //    public private(set) var references: [String: ImageReference] {
    //    access(keyPath: \.index)
    //    index?.interfaceLanguages ?? [:]
    //}

    /// The unique identifiers of the archives that are included in the documentation index.
    public var includedArchiveIdentifiers: [String] {
        access(keyPath: \.index)
        return index?.includedArchiveIdentifiers ?? []
    }

    @MainActor
    public func bootstrap() async throws {
        Self.logger.info("bootstrap Index for '\(self.identifier)'")

        let context = context
        let identifier = identifier

        do {
            let index = try await Task {
                try await context.index(for: identifier)
            }.value

            withMutation(keyPath: \.root) {
                root.append(nodesOf: index)
            }
        } catch let error as any DescribedError {
            Self.logger.error("failed to bootstrap index for '\(self.identifier)': \(error.errorDescription)")
            throw error
        } catch {
            Self.logger.error("failed to bootstrap index for '\(self.identifier)': \(error)")
            throw error
        }
    }
}

extension NavigatorIndex {
    @Observable
    public final class RootNode {
        private let bundleIdentifier: BundleIdentifier
        public var children: [Node] = []

        public init(bundleIdentifier: BundleIdentifier, children: [Node] = []) {
            self.bundleIdentifier = bundleIdentifier
            self.children = children
        }

        public func append(nodesOf index: DocumentationIndex) {
            let children = index.interfaceLanguages.values.map { (language: SourceLanguage, children: [DocumentationIndex.Node]) in
                let langReference = TopicReference(
                    bundleIdentifier: bundleIdentifier,
                    path: "",
                    sourceLanguage: language
                )

                return Node(
                    title: language.name,
                    children: children.map({ Node(resolving: $0, at: langReference) }),
                    reference: langReference,
                    type: .languageGroup
                )
            }

            self.children = children
        }
    }

    public final class Node: Identifiable, Sendable {
        /// The title of the node, suitable for presentation.
        public let title: String

        /// The children of the node if it has any
        public let children: [Node]?

        /// The relative path to the page represented by this node.
        public let reference: TopicReference?

        /// The type of this node.
        public let type: PageType

        init(title: String, children: [Node]?, reference: TopicReference?, type: PageType) {
            self.title = title
            self.children = children
            self.reference = reference
            self.type = type
        }

        convenience init(resolving node: DocumentationIndex.Node, at parentReference: TopicReference) {
            if let path = node.path {
                let reference = parentReference.appendingPath(path)

                self.init(
                    title: node.title,
                    children: node.children?.map({ Node(resolving: $0, at: reference) }),
                    reference: reference,
                    type: node.type
                )
            } else {
                if node.children?.isEmpty == false {
                    fatalError("Node without reference may not have children")
                }
                self.init(
                    title: node.title,
                    children: nil,
                    reference: nil,
                    type: node.type
                )
            }
        }
//        init(bundle: DocumentationBundle, from index: DocumentationIndex) {
//            let rootReference = TopicReference(bundleIdentifier: bundle.identifier, path: "")
//
//            let nodes = index.interfaceLanguages.languages.map { language in
//                let parentReference = rootReference.appendingPath(language)
//                Node(
//                    title: language.capitalized,
//                    children: children,
//                    reference: ,
//                    type: <#T##PageType#>
//                )
//            }
//        }
    }
}


public struct TopicReference: Sendable, Hashable, Equatable, CustomStringConvertible  {
    public var description: String {
        "Topic(\(url.absoluteString))"
    }
    /// The URL scheme for `doc://` links.
    public static let urlScheme = "doc"

    typealias ReferenceBundleIdentifier = String
    private struct ReferenceKey: Hashable {
        var path: String
        var fragment: String?
        var sourceLanguages: Set<SourceLanguage>
    }

    public func withFragment(_ fragment: String?) -> TopicReference {
        let newReference = TopicReference(
            bundleIdentifier: bundleIdentifier,
            path: path,
            fragment: fragment.map(urlReadableFragment),
            sourceLanguages: sourceLanguages
        )

        return newReference
    }

    /// Creates a new topic reference by appending a path to this reference.
    ///
    /// Before appending the path, it is encoded in a human readable format that avoids percent escape encoding in the URL.
    ///
    /// - Parameter path: The path to append.
    /// - Returns: The resulting topic reference.
    public func appendingPath(_ path: String) -> TopicReference {
        let newReference = TopicReference(
            bundleIdentifier: bundleIdentifier,
            urlReadablePath: url.appendingPathComponent(urlReadablePath(path), isDirectory: false).path,
            sourceLanguages: sourceLanguages
        )
        return newReference
    }

//    /// A synchronized reference cache to store resolved references.
//    private static var sharedPool = Synchronized([ReferenceBundleIdentifier: [ReferenceKey: ResolvedTopicReference]]())
//
//    /// Clears cached references belonging to the bundle with the given identifier.
//    /// - Parameter bundleIdentifier: The identifier of the bundle to which the method should clear belonging references.
//    static func purgePool(for bundleIdentifier: String) {
//        sharedPool.sync { $0.removeValue(forKey: bundleIdentifier) }
//    }

//    /// Enables reference caching for any identifiers created with the given bundle identifier.
//    static func enableReferenceCaching(for bundleIdentifier: ReferenceBundleIdentifier) {
//        sharedPool.sync { sharedPool in
//            if !sharedPool.keys.contains(bundleIdentifier) {
//                sharedPool[bundleIdentifier] = [:]
//            }
//        }
//    }


    /// Returns `true` if the passed `URL` has a "doc" URL scheme.
    public static func urlHasResolvedTopicScheme(_ url: URL?) -> Bool {
        return url?.scheme?.lowercased() == TopicReference.urlScheme
    }

    /// The storage for the resolved topic reference's state.
    let _storage: Storage

    public var url: URL {
        return _storage.url
    }

    /// The identifier of the bundle that owns this documentation topic.
    public var bundleIdentifier: String {
        return _storage.bundleIdentifier
    }

    /// The absolute path from the bundle to this topic, delimited by `/`.
    public var path: String {
        return _storage.path
    }

    /// A URL fragment referring to a resource in the topic.
    public var fragment: String? {
        return _storage.fragment
    }

    /// The source language for which this topic is relevant.
    public var sourceLanguage: SourceLanguage {
        // Return Swift by default to maintain backwards-compatibility.
        return sourceLanguages.contains(.swift) ? .swift : sourceLanguages.first!
    }

    /// The source languages for which this topic is relevant.
    ///
    /// > Important: The source languages associated with the reference may not be the same as the available source languages of its
    /// corresponding ``DocumentationNode``. If you need to query the source languages associated with a documentation node, use
    /// ``DocumentationContext/sourceLanguages(for:)`` instead.
    public var sourceLanguages: Set<SourceLanguage> {
        return _storage.sourceLanguages
    }

    /// - Note: The `path` parameter is escaped to a path readable string.
    public init(bundleIdentifier: String, path: String, fragment: String? = nil, sourceLanguage: SourceLanguage) {
        self.init(bundleIdentifier: bundleIdentifier, path: path, fragment: fragment, sourceLanguages: [sourceLanguage])
    }

    public init(bundleIdentifier: String, path: String, fragment: String? = nil, sourceLanguages: Set<SourceLanguage>) {
        self.init(
            bundleIdentifier: bundleIdentifier,
            urlReadablePath: urlReadablePath(path),
            urlReadableFragment: fragment.map({ urlReadableFragment($0) }),
            sourceLanguages: sourceLanguages
        )
    }

    private init(bundleIdentifier: String, urlReadablePath: String, urlReadableFragment: String? = nil, sourceLanguages: Set<SourceLanguage>) {
        precondition(!sourceLanguages.isEmpty, "ResolvedTopicReference.sourceLanguages cannot be empty")
        _storage = Storage(
            bundleIdentifier: bundleIdentifier,
            path: urlReadablePath,
            fragment: urlReadableFragment,
            sourceLanguages: sourceLanguages
        )
    }

    struct Storage: Sendable, Hashable, Equatable {
        let bundleIdentifier: String
        let path: String
        let fragment: String?
        let sourceLanguages: Set<SourceLanguage>
        let identifierPathAndFragment: String

        let url: URL

        let pathComponents: [String]

        let absoluteString: String

        init(
            bundleIdentifier: String,
            path: String,
            fragment: String? = nil,
            sourceLanguages: Set<SourceLanguage>
        ) {
            self.bundleIdentifier = bundleIdentifier
            self.path = path
            self.fragment = fragment
            self.sourceLanguages = sourceLanguages
            self.identifierPathAndFragment = "\(bundleIdentifier)\(path)\(fragment ?? "")"

            var components = URLComponents()
            components.scheme = TopicReference.urlScheme
            components.host = bundleIdentifier
            components.path = path
            components.fragment = fragment
            self.url = components.url!
            self.pathComponents = self.url.pathComponents
            self.absoluteString = self.url.absoluteString
        }
    }
}

/// An RFC 3986 compliant URL.
///
/// Use this wrapper type to make sure your stored URLs comply
/// to RFC 3986 that `URLComponents` implements, rather than the less-
/// strict implementation of `URL`.
///
/// For example, due to older RFC compliance, `URL` fails to parse relative topic
/// references with a fragment like this:
///  - `URL(string: "doc:tutorial#test")?.fragment` -> `nil`
///  - `URLComponents(string: "doc:tutorial#test")?.fragment` -> `"test"`
/// ## See Also
///  - [RFC 3986](http://www.ietf.org/rfc/rfc3986.txt)
public struct ValidatedURL: Hashable, Equatable {
    /// The raw components that make up the validated URL.
    public private(set) var components: URLComponents

    /// Creates a new RFC 3986 valid URL by using the given string URL.
    ///
    /// Will return `nil` when the given `string` is not a valid URL.
    /// - Parameter string: Source URL address as string
    ///
    /// > Note:
    /// > Attempting to parse a symbol path as a URL may result in unexpected URL components depending on the source language.
    /// > For example; an Objective-C instance method named `someMethodWithFirstValue:secondValue:` would be parsed as a
    /// > URL with the "someMethodWithFirstValue" scheme which is a valid link but which won't resolve to the intended symbol.
    /// >
    /// > When working with symbol destinations use ``init(symbolPath:)`` instead.
    /// >
    /// > When working with authored documentation links use ``init(parsingAuthoredLink:)`` instead.
    init?(parsingExact string: String) {
        guard let components = URLComponents(string: string) else {
            return nil
        }
        self.components = components
    }

    /// Creates a new RFC 3986 valid URL by using the given string URL and percent escaping the fragment component if necessary.
    ///
    /// Will return `nil` when the given `string` is not a valid URL.
    /// - Parameter string: Source URL address as string.
    ///
    /// If the parsed fragment component contains characters not allowed in the fragment of a URL, those characters will be percent encoded.
    ///
    /// Use this to parse author provided documentation links that may contain links to on-page subsections. Escaping the fragment allows authors
    /// to write links to subsections using characters that wouldn't otherwise be allowed in a fragment of a URL.
    init?(parsingAuthoredLink string: String) {
        // Try to parse the string without escaping anything
        if let parsed = ValidatedURL(parsingExact: string) {
            self.components = parsed.components
            return
        }

        // If the `URLComponents(string:)` parsing in `init(parsingExact:)` failed try a fallback that attempts to individually
        // percent encode each component.
        //
        // This fallback parsing tries to determine the substrings of the authored link that correspond to the scheme, bundle
        // identifier, path, and fragment of a documentation link or symbol link. It is not meant to work with general links.
        //
        // By identifying the subranges they can each be individually percent encoded with the characters that are allowed for
        // that component. This allows authored links to contain characters that wouldn't otherwise be valid in a general URL.
        //
        // Assigning the percent encoded values to `URLComponents/percentEncodedHost`, URLComponents/percentEncodedPath`, and
        // URLComponents/percentEncodedFragment` allow for the creation of a `URLComponents` value with special characters.
        var components = URLComponents()
        var remainder = string[...]

        // See if the link is a documentation link and try to split out the scheme and bundle identifier. If the link isn't a
        // documentation link it's assumed that it's a symbol link that start with the path component.
        // Other general URLs should have been successfully parsed with `URLComponents(string:)` in `init(parsingExact:)` above.
        if remainder.hasPrefix("\(TopicReference.urlScheme):") {
            // The authored link is a doc link
            components.scheme = TopicReference.urlScheme
            remainder = remainder.dropFirst("\(TopicReference.urlScheme):".count)

            if remainder.hasPrefix("//") {
                // The authored link includes a bundle ID
                guard let startOfPath = remainder.dropFirst(2).firstIndex(of: "/") else {
                    // The link started with "doc://" but didn't contain another "/" to start of the path.
                    return nil
                }
                components.percentEncodedHost = String(remainder[..<startOfPath]).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                remainder = remainder[startOfPath...]
            }
        }

        // This either is the start of a symbol link or the remainder of a doc link after the scheme and bundle ID was parsed.
        // This means that the remainder of the string is a path with an optional fragment. No other URL components are supported
        // by documentation links and symbol links.
        if let fragmentSeparatorIndex = remainder.firstIndex(of: "#") {
            // Encode the path substring and fragment substring separately
            guard let path = String(remainder[..<fragmentSeparatorIndex]).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                return nil
            }
            components.percentEncodedPath = path
            components.percentEncodedFragment = String(remainder[fragmentSeparatorIndex...].dropFirst()).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        } else {
            // Since the link didn't include a fragment, the rest of the string is the path.
            guard let path = String(remainder).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                return nil
            }
            components.percentEncodedPath = path
        }

        self.components = components
    }

    /// Creates a new RFC 3986 valid URL from the given URL.
    ///
    /// Will return `nil` when the given URL doesn't comply with RFC 3986.
    /// - Parameter url: Source URL
    init?(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        self.components = components
    }

    /// Creates a new RFC 3986 valid URL by using the given symbol path.
    ///
    /// - Parameter symbolDestination: A symbol path as a string, with path components separated by "/".
    init(symbolPath: String) {
        // Symbol links are assumed to be written as the path only, without a scheme or host component.
        var components = URLComponents()
        components.path = symbolPath
        self.components = components
    }

    /// Creates a new RFC 3986 valid URL.
    init(components: URLComponents) {
        self.components = components
    }

    /// Returns the unmodified value in case the URL matches the required scheme or nil otherwise.
    /// - Parameter scheme: A URL scheme to match.
    /// - Returns: A valid URL if the scheme matches, `nil` otherwise.
    func requiring(scheme: String) -> ValidatedURL? {
        guard scheme == components.scheme else { return nil }
        return self
    }

    /// The URL as an absolute string.
    var absoluteString: String {
        return components.string!
    }

    /// The URL as an RFC 3986 compliant `URL` value.
    var url: URL {
        return components.url!
    }
}


/// Creates a more readable version of a path by replacing characters that are not allowed in the path of a URL with hyphens.
///
/// If this step is not performed, the disallowed characters are instead percent escape encoded instead which is less readable.
/// For example, a path like `"hello world/example project"` is converted to `"hello-world/example-project"`
/// instead of `"hello%20world/example%20project"`.
func urlReadablePath(_ path: some StringProtocol) -> String {
    return path.components(separatedBy: .urlPathNotAllowed).joined(separator: "-")
}

private extension CharacterSet {
    /// Returns the character set for characters **not** allowed in a path URL component.
    static let urlPathNotAllowed = CharacterSet.urlPathAllowed.inverted

    /// Returns the union of the `whitespaces` and `punctuationCharacters` character sets.
    static let whitespacesAndPunctuation = CharacterSet.whitespaces.union(.punctuationCharacters)

    // For fragments
    static let fragmentCharactersToRemove = CharacterSet.punctuationCharacters // Remove punctuation from fragments
        .union(CharacterSet(charactersIn: "`"))       // Also consider back-ticks as punctuation. They are used as quotes around symbols or other code.
        .subtracting(CharacterSet(charactersIn: "-")) // Don't remove hyphens. They are used as a whitespace replacement.
    static let whitespaceAndDashes = CharacterSet.whitespaces
        .union(CharacterSet(charactersIn: "-–—")) // hyphen, en dash, em dash
}

/// Creates a more readable version of a fragment by replacing characters that are not allowed in the fragment of a URL with hyphens.
///
/// If this step is not performed, the disallowed characters are instead percent escape encoded, which is less readable.
/// For example, a fragment like `"#hello world"` is converted to `"#hello-world"` instead of `"#hello%20world"`.
func urlReadableFragment(_ fragment: some StringProtocol) -> String {
    var fragment = fragment
    // Trim leading/trailing whitespace
        .trimmingCharacters(in: .whitespaces)

    // Replace continuous whitespace and dashes
        .components(separatedBy: .whitespaceAndDashes)
        .filter({ !$0.isEmpty })
        .joined(separator: "-")

    // Remove invalid characters
    fragment.unicodeScalars.removeAll(where: CharacterSet.fragmentCharactersToRemove.contains)

    return fragment
}
