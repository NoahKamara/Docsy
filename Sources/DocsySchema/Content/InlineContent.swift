import Foundation

public typealias InlineContents = [InlineContent]

public enum InlineContent: Equatable, Hashable, Sendable {
    // MARK: Plain

    /// A piece of plain text.
    case text(String)

    // MARK: Text Style

    /// A piece of code like a variable name or a single operator.
    case codeVoice(code: String)
    /// An emphasized piece of inline content.
    case emphasis(inlineContent: [InlineContent])
    /// A strongly emphasized piece of inline content.
    case strong(inlineContent: [InlineContent])
    /// A strikethrough piece of content.
    case strikethrough(inlineContent: [InlineContent])
    /// A subscript piece of content.
    case `subscript`(inlineContent: [InlineContent])
    /// A superscript piece of content.
    case superscript(inlineContent: [InlineContent])

    // MARK: Embeddings & References

    /// An image element.
    case image(identifier: ReferenceIdentifier, metadata: ContentMetadata?)
    /// A reference to another resource.
    case reference(identifier: ReferenceIdentifier, isActive: Bool, overridingTitle: String?, overridingTitleInlineContent: [InlineContent]?)

    /// A piece of content that introduces a new term.
    case newTerm(inlineContent: [InlineContent])
    /// An inline heading.
    case inlineHead(inlineContent: [InlineContent])
}

// MARK: Decodable

extension InlineContent: Decodable {
    private enum InlineType: String, Codable {
        case codeVoice
        case emphasis
        case strong
        case image
        case reference
        case text
        case newTerm
        case inlineHead
        case `subscript`
        case superscript
        case strikethrough
    }

    private enum CodingKeys: CodingKey {
        case type
        case code
        case inlineContent
        case identifier
        case title
        case destination
        case text
        case isActive
        case overridingTitle
        case overridingTitleInlineContent
        case metadata
    }

    private var type: InlineType {
        switch self {
        case .codeVoice: .codeVoice
        case .emphasis: .emphasis
        case .strong: .strong
        case .image: .image
        case .reference: .reference
        case .text: .text
        case .subscript: .subscript
        case .superscript: .superscript
        case .newTerm: .newTerm
        case .inlineHead: .inlineHead
        case .strikethrough: .strikethrough
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(InlineType.self, forKey: .type)
        switch type {
        case .codeVoice:
            self = try .codeVoice(code: container.decode(String.self, forKey: .code))
        case .emphasis:
            self = try .emphasis(inlineContent: container.decode([Self].self, forKey: .inlineContent))
        case .strong:
            self = try .strong(inlineContent: container.decode([Self].self, forKey: .inlineContent))
        case .image:
            self = try .image(
                identifier: container.decode(ReferenceIdentifier.self, forKey: .identifier),
                metadata: container.decodeIfPresent(ContentMetadata.self, forKey: .metadata)
            )
        case .reference:
            let identifier = try container.decode(ReferenceIdentifier.self, forKey: .identifier)
            let overridingTitle: String?
            let overridingTitleInlineContent: [Self]?

            if let formattedOverridingTitle = try container.decodeIfPresent([Self].self, forKey: .overridingTitleInlineContent) {
                overridingTitleInlineContent = formattedOverridingTitle
                overridingTitle = try container.decodeIfPresent(String.self, forKey: .overridingTitle) ?? formattedOverridingTitle.plainText
            } else if let plainTextOverridingTitle = try container.decodeIfPresent(String.self, forKey: .overridingTitle) {
                overridingTitleInlineContent = [.text(plainTextOverridingTitle)]
                overridingTitle = plainTextOverridingTitle
            } else {
                overridingTitleInlineContent = nil
                overridingTitle = nil
            }

            self = try .reference(identifier: identifier,
                                  isActive: container.decode(Bool.self, forKey: .isActive),
                                  overridingTitle: overridingTitle,
                                  overridingTitleInlineContent: overridingTitleInlineContent)
        case .text:
            self = try .text(container.decode(String.self, forKey: .text))
        case .newTerm:
            self = try .newTerm(inlineContent: container.decode([Self].self, forKey: .inlineContent))
        case .inlineHead:
            self = try .inlineHead(inlineContent: container.decode([Self].self, forKey: .inlineContent))
        case .subscript:
            self = try .subscript(inlineContent: container.decode([Self].self, forKey: .inlineContent))
        case .superscript:
            self = try .superscript(inlineContent: container.decode([Self].self, forKey: .inlineContent))
        case .strikethrough:
            self = try .strikethrough(inlineContent: container.decode([Self].self, forKey: .inlineContent))
        }
    }
}

// MARK: Metadata

/// Additional metadata that might belong to a content element.
public struct ContentMetadata: Equatable, Hashable, Decodable, Sendable {
    /// named anchor
    public var anchor: String?
    /// custom title.
    public var title: String?
    /// custom abstract.
    public var abstract: [InlineContent]?
    /// identifier for the device frame that should wrap this element.
    /// > for screenshot images
    public var deviceFrame: String?
}

// MARK: Lossy PlainText conversion

public extension InlineContent {
    /// Returns a lossy conversion of the formatted content to a plain-text string.
    ///
    /// This implementation is necessarily limited because it doesn't make
    /// use of any collected `RenderReference` items. In many cases, it may make
    /// more sense to use the `rawIndexableTextContent` function that does use `RenderReference`
    /// for a more accurate textual representation of `InlineContent.image` and
    /// `InlineContent.reference`.
    var plainText: String {
        switch self {
        case .codeVoice(let code):
            code
        case .emphasis(let inlineContent):
            inlineContent.plainText
        case .strong(let inlineContent):
            inlineContent.plainText
        case .image(_, let metadata):
            (metadata?.abstract?.plainText) ?? ""
        case .reference(_, _, let overridingTitle, let overridingTitleInlineContent):
            overridingTitle ?? overridingTitleInlineContent?.plainText ?? ""
        case .text(let text):
            text
        case .newTerm(let inlineContent):
            inlineContent.plainText
        case .inlineHead(let inlineContent):
            inlineContent.plainText
        case .subscript(let inlineContent):
            inlineContent.plainText
        case .superscript(let inlineContent):
            inlineContent.plainText
        case .strikethrough(let inlineContent):
            inlineContent.plainText
        }
    }
}

public extension Sequence<InlineContent> {
    /// Returns a lossy conversion of the formatted content to a plain-text string.
    var plainText: String {
        map(\.plainText).joined()
    }
}
