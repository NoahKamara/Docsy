import Foundation

public extension Document {
    /// Arbitrary metadata for a document.
    struct Metadata {
        // MARK: Tutorials metadata

        /// The name of technology associated with a tutorial.
        public let category: String?
        public let categoryPathComponent: String?
        /// A description of the estimated time to complete the tutorials of a technology.
        public let estimatedTime: String?

        // MARK: Symbol metadata

        /// The modules that the symbol is apart of.
        public let modules: [Module]?

        /// The name of the module extension in which the symbol is defined, if applicable.
        public let extendedModule: String?

        /// The platform availability information about a symbol.
        public let platforms: [PlatformAvailability]?

        /// Whether protocol method is required to be implemented by conforming types.
        public let required: Bool

        /// A heading describing the type of the document.
        public let roleHeading: String?

        /// The role of the document.
        ///
        /// Examples of document roles include "symbol" or "sampleCode".
        public let role: String?

        /// Custom authored images that represent this page.
        public let images: [TopicImage]

        /// Custom authored color that represents this page.
        public let color: TopicColor?

        /// The title of the page.
        public var title: String?

        /// Author provided custom metadata describing the page.
        public let customMetadata: [String: String]

        /// The title of the page.
        /// An identifier for a symbol generated externally.
        public let externalID: String?

        /// The kind of a symbol, e.g., "class" or "func".
        public let symbolKind: String?

        /// The access level of a symbol, e.g., "public" or "private".
        public let symbolAccessLevel: String?

        /// Abbreviated declaration to display in links.
        public let fragments: [DeclarationSection.Token]?

        /// Abbreviated declaration to display in navigators.
        public let navigatorTitle: [DeclarationSection.Token]?

        /// Additional metadata associated with the document.
        public var extraMetadata: [CodingKeys: Any] = [:]

        /// Information the availability of generic APIs.
        public let conformance: ConformanceSection?

        /// The URI of the source file in which the symbol was originally declared, suitable for display in a user interface.
        ///
        /// This information may not (and should not) always be available for many reasons,
        /// such as compiler infrastructure limitations, or filesystem privacy and security concerns.
        public let sourceFileURI: String?

        /// The remote location where the source declaration of the topic can be viewed.
        public let remoteSource: RemoteSource?

        /// Any tags assigned to the node.
        public let tags: [Tag]?

        /// Whether there isn't a version of the page with more content that a renderer can link to.
        ///
        /// This property indicates to renderers that an expanded version of the page does not exist for this document,
        /// which, for example, controls whether a 'View More' link should be displayed or not.
        ///
        /// It's the renderer's responsibility to fetch the full version of the page, for example using
        /// the ``RenderNode/variants`` property.
        public let hasNoExpandedDocumentation: Bool
    }
}

extension Document.Metadata: Decodable {
    /// A list of pre-defined roles to assign to nodes.
    public enum Role: String, Equatable {
        case symbol, containerSymbol, restRequestSymbol, dictionarySymbol, pseudoSymbol,
             pseudoCollection, collection, collectionGroup, article, sampleCode, unknown
        case table, codeListing, link, subsection, task, overview
        case tutorial = "project"
    }

    /// Metadata about a module dependency.
    public struct Module: Codable, Equatable {
        public let name: String
        /// Possible dependencies to the module, we allow for those in the render JSON model
        /// but have no authoring support at the moment.
        public let relatedModules: [String]?
    }

    /// Describes the location of the topic's source code, hosted remotely by a source service.
    public struct RemoteSource: Codable, Equatable {
        /// The name of the file where the topic is declared.
        public let fileName: String

        /// The location of the topic's source code, hosted by a source service.
        public let url: URL

        /// Creates a topic's source given its source code's file name and URL.
        public init(fileName: String, url: URL) {
            self.fileName = fileName
            self.url = url
        }
    }

    public struct CodingKeys: CodingKey, Hashable, Equatable {
        public let stringValue: String

        public init(stringValue: String) {
            self.stringValue = stringValue
        }

        public var intValue: Int? {
            nil
        }

        public init?(intValue _: Int) {
            nil
        }

        public static let category = CodingKeys(stringValue: "category")
        public static let categoryPathComponent = CodingKeys(stringValue: "categoryPathComponent")
        public static let estimatedTime = CodingKeys(stringValue: "estimatedTime")
        public static let modules = CodingKeys(stringValue: "modules")
        public static let extendedModule = CodingKeys(stringValue: "extendedModule")
        public static let platforms = CodingKeys(stringValue: "platforms")
        public static let required = CodingKeys(stringValue: "required")
        public static let roleHeading = CodingKeys(stringValue: "roleHeading")
        public static let role = CodingKeys(stringValue: "role")
        public static let title = CodingKeys(stringValue: "title")
        public static let externalID = CodingKeys(stringValue: "externalID")
        public static let symbolKind = CodingKeys(stringValue: "symbolKind")
        public static let symbolAccessLevel = CodingKeys(stringValue: "symbolAccessLevel")
        public static let conformance = CodingKeys(stringValue: "conformance")
        public static let fragments = CodingKeys(stringValue: "fragments")
        public static let navigatorTitle = CodingKeys(stringValue: "navigatorTitle")
        public static let sourceFileURI = CodingKeys(stringValue: "sourceFileURI")
        public static let remoteSource = CodingKeys(stringValue: "remoteSource")
        public static let tags = CodingKeys(stringValue: "tags")
        public static let images = CodingKeys(stringValue: "images")
        public static let color = CodingKeys(stringValue: "color")
        public static let customMetadata = CodingKeys(stringValue: "customMetadata")
        public static let hasNoExpandedDocumentation = CodingKeys(
            stringValue: "hasNoExpandedDocumentation")
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        category = try container.decodeIfPresent(String.self, forKey: .category)
        categoryPathComponent = try container.decodeIfPresent(String.self, forKey: .categoryPathComponent)

        platforms = try container.decodeIfPresent([PlatformAvailability].self, forKey: .platforms)
        modules = try container.decodeIfPresent([Module]?.self, forKey: .modules) ?? []
        extendedModule = try container.decodeIfPresent(String.self, forKey: .extendedModule)
        estimatedTime = try container.decodeIfPresent(String.self, forKey: .estimatedTime)
        required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
        roleHeading = try container.decodeIfPresent(String.self, forKey: .roleHeading)
        images = try container.decodeIfPresent([TopicImage].self, forKey: .images) ?? []
        color = try container.decodeIfPresent(TopicColor.self, forKey: .color)
        customMetadata = try container.decodeIfPresent([String: String].self, forKey: .customMetadata) ?? [:]
        let rawRole = try container.decodeIfPresent(String.self, forKey: .role)
        role = rawRole == "tutorial" ? Role.tutorial.rawValue : rawRole
        title = try container.decodeIfPresent(String.self, forKey: .title)
        externalID = try container.decodeIfPresent(String.self, forKey: .externalID)
        symbolKind = try container.decodeIfPresent(String.self, forKey: .symbolKind)
        symbolAccessLevel = try container.decodeIfPresent(String.self, forKey: .symbolAccessLevel)
        conformance = try container.decodeIfPresent(ConformanceSection.self, forKey: .conformance)
        fragments = try container.decodeIfPresent([DeclarationSection.Token].self, forKey: .fragments)
        navigatorTitle = try container.decodeIfPresent([DeclarationSection.Token].self, forKey: .navigatorTitle)
        sourceFileURI = try container.decodeIfPresent(String.self, forKey: .sourceFileURI)
        remoteSource = try container.decodeIfPresent(RemoteSource.self, forKey: .remoteSource)
        tags = try container.decodeIfPresent([Document.Tag].self, forKey: .tags)
        hasNoExpandedDocumentation = try container.decodeIfPresent(Bool.self, forKey: .hasNoExpandedDocumentation) ?? false

        let extraKeys = Set(container.allKeys).subtracting(
            [
                .category,
                .categoryPathComponent,
                .estimatedTime,
                .modules,
                .extendedModule,
                .platforms,
                .required,
                .roleHeading,
                .role,
                .title,
                .externalID,
                .symbolKind,
                .symbolAccessLevel,
                .conformance,
                .fragments,
                .navigatorTitle,
                .sourceFileURI,
                .remoteSource,
                .tags,
                .hasNoExpandedDocumentation,
            ]
        )
        for extraKey in extraKeys {
            extraMetadata[extraKey] = try container.decode(AnyMetadata.self, forKey: extraKey).value
        }
    }
}

/// A type-erasing container for metadata.
public struct AnyMetadata {
    /// The metadata value.
    public var value: Any

    public init(_ value: Any) {
        self.value = value
    }
}

extension AnyMetadata: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.value = ()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyMetadata].self) {
            self.value = array.map(\.value)
        } else if let dictionary = try? container.decode([String: AnyMetadata].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyMetadata failed to decode the value.")
        }
    }
}
