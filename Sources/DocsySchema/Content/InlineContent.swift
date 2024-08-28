import Foundation

public typealias InlineContents = [InlineContent]

public enum InlineContent: Equatable, Hashable, Sendable {
    /// A piece of code like a variable name or a single operator.
    case codeVoice(code: String)
    /// An emphasized piece of inline content.
    case emphasis(inlineContent: [InlineContent])
    /// A strongly emphasized piece of inline content.
    case strong(inlineContent: [InlineContent])
    /// An image element.
    case image(identifier: ReferenceIdentifier, metadata: ContentMetadata?)
    /// A reference to another resource.
    case reference(identifier: ReferenceIdentifier, isActive: Bool, overridingTitle: String?, overridingTitleInlineContent: [InlineContent]?)
    /// A piece of plain text.
    case text(String)
    /// A piece of content that introduces a new term.
    case newTerm(inlineContent: [InlineContent])
    /// An inline heading.
    case inlineHead(inlineContent: [InlineContent])
    /// A subscript piece of content.
    case `subscript`(inlineContent: [InlineContent])
    /// A superscript piece of content.
    case superscript(inlineContent: [InlineContent])
    /// A strikethrough piece of content.
    case strikethrough(inlineContent: [InlineContent])
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
        case .codeVoice: return .codeVoice
        case .emphasis: return .emphasis
        case .strong: return .strong
        case .image: return .image
        case .reference: return .reference
        case .text: return .text
        case .subscript: return .subscript
        case .superscript: return .superscript
        case .newTerm: return .newTerm
        case .inlineHead: return .inlineHead
        case .strikethrough: return .strikethrough
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
                identifier: container.decode(ReferenceIdentifier.self, forKey: . identifier),
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
extension InlineContent {
    /// Returns a lossy conversion of the formatted content to a plain-text string.
    ///
    /// This implementation is necessarily limited because it doesn't make
    /// use of any collected `RenderReference` items. In many cases, it may make
    /// more sense to use the `rawIndexableTextContent` function that does use `RenderReference`
    /// for a more accurate textual representation of `InlineContent.image` and
    /// `InlineContent.reference`.
    public var plainText: String {
        switch self {
        case let .codeVoice(code):
            return code
        case let .emphasis(inlineContent):
            return inlineContent.plainText
        case let .strong(inlineContent):
            return inlineContent.plainText
        case let .image(_, metadata):
            return (metadata?.abstract?.plainText) ?? ""
        case let .reference(_, _, overridingTitle, overridingTitleInlineContent):
            return overridingTitle ?? overridingTitleInlineContent?.plainText ?? ""
        case let .text(text):
            return text
        case let .newTerm(inlineContent):
            return inlineContent.plainText
        case let .inlineHead(inlineContent):
            return inlineContent.plainText
        case let .subscript(inlineContent):
            return inlineContent.plainText
        case let .superscript(inlineContent):
            return inlineContent.plainText
        case let .strikethrough(inlineContent):
            return inlineContent.plainText
        }
    }
}

extension Sequence<InlineContent> {
    /// Returns a lossy conversion of the formatted content to a plain-text string.
    public var plainText: String {
        return map { $0.plainText }.joined()
    }
}
