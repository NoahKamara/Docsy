import Foundation

public protocol TopicContent {
    associatedtype CodingKeys: CodingKey
}

public struct Document: Decodable {
    /// The current version of the document schema.
    public let schemaVersion: SemanticVersion

    /// The identifier of the document.
    ///
    /// > The identifier of a document is typically the same as the documentation node it's representing.
    public let identifier: TopicReference

    /// The kind of this documentation node.
    public let kind: Kind

    /// The references used in the document. These can be references to other nodes, media, and more.
    ///
    /// The key for each reference is the ``ReferenceIdentifier/identifier`` of the reference's ``RenderReference/identifier``.
    public let references: [String: Reference]

    /// Hierarchy information about the context in which this documentation node is placed.
    public let hierarchy: Hierarchy?

    /// Arbitrary metadata information about the document.
    public let metadata: Metadata

    // MARK: Reference documentation nodes

    /// The default value for the abstract of the node, which provides a short overview of its contents.
    public let abstract: [InlineContent]?

//    /// The default value of the main sections of a reference documentation node.
//    public let primaryContentSections: [Document.Section]
//
//    /// The variants of the primary content sections of the node, which are the main sections of a reference documentation node.
//    public let primaryContentSectionsVariants: [VariantCollection<CodableContentSection?>] = []
//
//    /// The visual style that should be used when rendering this page's Topics section.
//    public let topicSectionsStyle: TopicsSectionStyle
//
//    /// The default Topics sections of this documentation node, which contain links to useful related documentation nodes.
//    public let topicSections: [TaskGroupRenderSection]
//
//    /// The default Relationships sections of a reference documentation node, which describes how this symbol is related to others.
//    public let relationshipSections: [RelationshipsRenderSection]
//
//    /// The default Default Implementations sections of symbol node, which list APIs that provide a default implementation of the symbol.
//    public let defaultImplementationsSections: [TaskGroupRenderSection]
//
//    /// The See Also sections of a node, which list documentation resources related to this documentation node.
//    public let seeAlsoSections: [TaskGroupRenderSection]
//
//    /// A description of why this symbol is deprecated.
//    public let deprecationSummary: [RenderBlockContent]?
//
//    /// List of variants of the same documentation node for various languages.
//    public let variants: [RenderNode.Variant]?
//
//    /// Language-specific overrides for documentation.
//    ///
//    /// This property holds overrides that clients should apply to the render JSON when processing documentation for specific languages. The overrides are
//    /// organized by traits (e.g., language) and it's up to the client to determine which trait is most appropriate for them. For example, a client that wants to
//    /// process the Objective-C version of documentation should apply the overrides associated with the `interfaceLanguage: objc` trait.
//    ///
//    /// The overrides are emitted in the [JSON Patch](https://datatracker.ietf.org/doc/html/rfc6902) format.
//    public let variantOverrides: VariantOverrides?
//
//    /// Information about what API diffs are available for this symbol.
//    public let diffAvailability: DiffAvailability?
//
//    // MARK: Sample code nodes
//
//    /// Download information for sample code nodes.
//    public let sampleDownload: SampleDownloadSection?
//
//    /// Download not available information.
//    public let downloadNotAvailableSummary: [RenderBlockContent]?
//
//    // MARK: Tutorials nodes
//
//    /// The sections of this node.
//    ///
//    /// For tutorial pages, this property is the top-level grouping for the page's contents.
//    public let sections: [RenderSection] = []

    /// The kind of content represented by this node.
    public enum Kind: String, Codable {
        case symbol
        case article
        case tutorial = "project"
        case section
        case overview

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            switch try container.decode(String.self) {
            case "symbol":
                self = .symbol
            case "article":
                self = .article
            case "tutorial", "project":
                self = .tutorial
            case "section":
                self = .section
            case "overview":
                self = .overview

            case let unknown:
                throw DecodingError.dataCorruptedError(
                    in: container, debugDescription: "Unknown RenderNode.Kind: '\(unknown)'.")
            }
        }
    }
}
