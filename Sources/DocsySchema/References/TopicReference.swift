import Foundation

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

extension TopicReference: Decodable {
    enum CodingKeys: CodingKey {
        case url, interfaceLanguage
    }

    public init(from decoder: Decoder) throws {
        enum TopicReferenceDeserializationError: Error {
            case unexpectedURLScheme(url: URL, scheme: String)
            case missingBundleIdentifier(url: URL)
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let url = try container.decode(URL.self, forKey: .url)
        guard TopicReference.urlHasResolvedTopicScheme(url) else {
            throw TopicReferenceDeserializationError.unexpectedURLScheme(url: url, scheme: url.scheme ?? "")
        }

        guard let bundleIdentifier = url.host else {
            throw TopicReferenceDeserializationError.missingBundleIdentifier(url: url)
        }

        let language = try container.decode(String.self, forKey: .interfaceLanguage)
        let interfaceLanguage = SourceLanguage(id: language)

        self.init(bundleIdentifier: bundleIdentifier, path: url.path, fragment: url.fragment, sourceLanguage: interfaceLanguage)
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
