/// A task group section that contains links to other symbols.
public struct TaskGroupSection: SectionProtocol, Equatable {
    public let kind: Kind = .taskGroup

    /// An optional title for the section.
    public let title: String?
    /// An optional abstract summary for the section.
    public let abstract: [InlineContent]?

    /// An optional discussion for the section.
    public var discussion: AnyContentSection?

    /// A list of topic graph references.
    public let identifiers: [String]
    /// If true, this is an automatically generated group. If false, this is an authored group.
    public let generated: Bool
    /// An optional anchor that can be used to link to the task group.
    public let anchor: String?

    /// The list of keys you use to encode or decode this section.
    private enum CodingKeys: CodingKey {
        case title, abstract, discussion, identifiers, generated, anchor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decodeIfPresent(String.self, forKey: .title)
        abstract = try container.decodeIfPresent([InlineContent].self, forKey: .abstract)
        identifiers = try container.decode([String].self, forKey: .identifiers)

        generated = try container.decodeIfPresent(Bool.self, forKey: .generated) ?? false
        anchor = try container.decodeIfPresent(String.self, forKey: .anchor)
        discussion = try container.decodeIfPresent(AnyContentSection.self, forKey: .discussion)
    }
}
