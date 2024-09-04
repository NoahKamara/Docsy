import Foundation
import OSLog

import OSLog

public class NavigatorIndex {
    static let logger = Logger.docsy("Index")

    public init() {
        tree = NavigatorTree()
    }

    /// A mapping of interface languages to the index nodes they contain.
    public var tree: NavigatorTree

    public var root: RootNode { tree.root }
}

public extension NavigatorIndex {
    func load(
        for bundle: DocumentationBundle,
        with dataProvider: any DocumentationContextDataProvider
    ) async throws {
        Self.logger.info("[\(bundle.identifier)] loading")

        let index: DocumentationIndex = try await {
            do {
                let data = try await dataProvider.contentsOfURL(bundle.indexURL, in: bundle)
                let index = try JSONDecoder().decode(DocumentationIndex.self, from: data)
                return index
            } catch let error as any DescribedError {
                Self.logger.error("[\(bundle.identifier)] failed: \(error.errorDescription)")
                throw error
            } catch {
                Self.logger.error("[\(bundle.identifier)] failed: \(error)")
                throw error
            }
        }()

        let bundleRoot = bundle.rootReference
        Self.logger.debug("[\(bundle.identifier)] found Index \(index.schemaVersion)")

        let langGroups = index.interfaceLanguages.values.map { lang, nodes in
            let children = nodes.map {
                Node(resolving: $0, at: bundleRoot)
            }
            Self.logger.debug("[\(bundle.identifier)] found language: \(lang.id) with \(nodes[0].title) elements")

            return LanguageGroup(lang, children: children)
        }

        let bundleNode = BundleNode(bundle: bundle, children: langGroups)
        await tree.root.insertBundle(bundleNode)
    }

    @MainActor
    func unload(bundle: DocumentationBundle) {
        Self.logger.info("[\(bundle.identifier)] unlodaing")
        tree.root.removeBundle(bundle.identifier)
    }
}

public extension NavigatorIndex {
    class NavigatorTree {
        public let root: RootNode

        public init() {
            root = RootNode()
        }

        public func dumpTree(for _: SourceLanguage = .swift) -> String {
            return root.treeLines().joined(separator: "\n")
        }
    }

    @Observable
    class Node: Identifiable {
        /// The title of the node, suitable for presentation.
        public let title: String

        /// The children of the node if it has any
        public private(set) var children: [Node]?

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

        convenience init(resolving node: DocumentationIndex.Node, at rootReference: TopicReference) {
            if let path = node.path {
                let reference = rootReference.appendingPath(path)

                self.init(
                    title: node.title,
                    children: node.children?.map { Node(resolving: $0, at: rootReference) },
                    reference: reference,
                    type: node.type
                )
            } else {
                if node.children?.isEmpty == false {
                    print("WARNING: Node without reference may not have children")
                }
                self.init(
                    title: node.title,
                    children: nil,
                    reference: nil,
                    type: node.type
                )
            }
        }

        public func tree() -> String {
            return treeLines().joined(separator: "\n")
        }

        func treeLines(prefix: String = "", isLast: Bool = true) -> [String] {
            var line = prefix

            if prefix != "" {
                line += isLast ? "╰─" : "├─"
            }

            line += "[\(type.rawValue)] \(title)"

            return if let children {
                children.enumerated().reduce(into: [line]) { result, element in
                    let (index, child) = element
                    let newPrefix = prefix + (isLast ? "    " : "│   ")
                    result += child.treeLines(prefix: newPrefix, isLast: index == children.count - 1)
                }
            } else {
                [line]
            }
        }
    }

    final class LanguageGroup: Node {
        public let language: SourceLanguage

        init(_ language: SourceLanguage, children: [NavigatorIndex.Node]? = nil) {
            self.language = language
            super.init(
                title: language.name,
                children: children,
                reference: nil,
                type: .languageGroup
            )
        }
    }

    @Observable
    final class BundleNode: Node {
        let identifier: BundleIdentifier

        public let availableLanguages: Set<SourceLanguage>

        init(bundle: DocumentationBundle, children: [LanguageGroup]) {
            identifier = bundle.identifier
            availableLanguages = Set(children.map(\.language))

            super.init(
                title: bundle.displayName,
                children: children,
                reference: nil,
                type: .root
            )
        }
    }

    @Observable
    class RootNode: Node {
        public var availableLanguages: Set<SourceLanguage> {
            access(keyPath: \.nodes)
            return nodes.values.map(\.availableLanguages).reduce(Set()) {
                $0.union($1)
            }
        }

        private var nodes: [BundleIdentifier: BundleNode] = [:]

        override public var children: [NavigatorIndex.Node]! {
            access(keyPath: \.nodes)
            return Array(nodes.values)
        }

        init() {
            super.init(
                title: "Root",
                children: [],
                reference: nil,
                type: .root
            )
        }

        @MainActor
        func insertBundle(_ bundle: BundleNode) {
            withMutation(keyPath: \.nodes[bundle.identifier]) {
                nodes[bundle.identifier] = bundle
            }
        }

        @MainActor
        func removeBundle(_ identifier: BundleIdentifier) {
            withMutation(keyPath: \.nodes[identifier]) {
                _ = nodes.removeValue(forKey: identifier)
            }
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
