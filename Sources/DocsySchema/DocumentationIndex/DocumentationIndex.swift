
import Foundation

public struct DocumentationIndex: Decodable, Equatable, Sendable {
    /// The current schema version of the Index JSON spec.
    public static let currentSchemaVersion = SemanticVersion(major: 0, minor: 1, patch: 2)

    /// The version of the RenderIndex spec that was followed when creating this index.
    public let schemaVersion: SemanticVersion

    /// A mapping of interface languages to the index nodes they contain.
    public private(set) var interfaceLanguages: InterfaceLanguages

    /// The values of the image references used in the documentation index.
//    public private(set) var references: [String: ImageReference]

    /// The unique identifiers of the archives that are included in the documentation index.
    public private(set) var includedArchiveIdentifiers: [String]

    /// Creates a new render index with the given interface language to node mapping.
    public init(
        interfaceLanguages: InterfaceLanguages,
//        references: [String: ImageReference] = [:],
        includedArchiveIdentifiers: [String]
    ) {
        schemaVersion = Self.currentSchemaVersion
        self.interfaceLanguages = interfaceLanguages
//        self.references = references
        self.includedArchiveIdentifiers = includedArchiveIdentifiers
    }

    enum CodingKeys: CodingKey {
        case schemaVersion
        case interfaceLanguages
//        case references
        case includedArchiveIdentifiers
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(SemanticVersion.self, forKey: .schemaVersion)
        interfaceLanguages = try container.decode(InterfaceLanguages.self, forKey: .interfaceLanguages)
//        self.references = try container.decodeIfPresent([String : ImageReference].self, forKey: .references) ?? [:]
        includedArchiveIdentifiers = try container.decodeIfPresent([String].self.self, forKey: .includedArchiveIdentifiers) ?? []
    }

//    public mutating func merge(_ other: DocumentationIndex) throws {
//        for (languageID, nodes) in other.interfaceLanguages {
//            interfaceLanguages[languageID, default: []].append(contentsOf: nodes)
//        }
//
//        try references.merge(other.references) { _, new in throw MergeError.referenceCollision(new.identifier.identifier) }
//
//        includedArchiveIdentifiers.append(contentsOf: other.includedArchiveIdentifiers)
//    }

    /// Insert a root node with a given name for each interface language and move the previous root node(s) under the new root node.
    /// - Parameter named: The name of the new root node
//    public mutating func insertRoot(named: String) {
//        for (languageID, nodes) in interfaceLanguages {
//            let root = Node(title: named, path: "/documentation", pageType: .framework, isDeprecated: false, children: nodes, icon: nil)
//            interfaceLanguages[languageID] = [root]
//        }
//    }

//    enum MergeError: DescribedError {
//        case referenceCollision(String)
//
//        var errorDescription: String {
//            switch self {
//            case .referenceCollision(let reference):
//                return "Collision merging image references. Reference \(reference.singleQuoted) exists in more than one input archive."
//            }
//        }
//    }
}

public extension DocumentationIndex {
    struct InterfaceLanguages: Equatable, Decodable, ExpressibleByDictionaryLiteral, Sendable {
        public typealias Values = [SourceLanguage: [Node]]

        public var languages: Values.Keys { values.keys }

        public let values: Values

        private init(values: Values) {
            self.values = values
        }

        public init(dictionaryLiteral elements: (SourceLanguage, [Node])...) {
            self.init(values: .init(uniqueKeysWithValues: elements))
        }

        public var swift: [Node]? { values[.swift] }

        public subscript(_ lang: SourceLanguage) -> [Node]? {
            values[lang]
        }

        enum CodingKeys: CodingKey {
            case values
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: SourceLanguageKey.self)

            let values = try container.allKeys.reduce(into: Values()) { partialResult, key in
                let nodes = try container.decode([Node].self, forKey: key)
                partialResult[key.lang] = nodes
            }

            self.init(values: values)
        }
    }
}

private struct SourceLanguageKey: CodingKey {
    let lang: SourceLanguage
    var stringValue: String { lang.linkDisambiguationID }
    var intValue: Int? { nil }

    init(stringValue: String) {
        lang = SourceLanguage(name: stringValue)
    }

    init?(intValue _: Int) {
        return nil
    }
}
