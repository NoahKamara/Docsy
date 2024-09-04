/// A reference to a URL.
public struct LinkReference: ReferenceProtocol, Equatable {
    /// The type of this link reference.
    ///
    /// This value is always `.link`.
    public let type: ReferenceType = .link

    /// The identifier of this reference.
    public let identifier: ReferenceIdentifier

    /// The plain text title of the destination page.
    public let title: String

    /// The formatted title of the destination page.
    public let titleInlineContent: [InlineContent]

    /// The topic url for the destination page.
    public let url: String

    init(identifier: ReferenceIdentifier, title: String, titleInlineContent: [InlineContent], url: String) {
        self.identifier = identifier
        self.title = title
        self.titleInlineContent = titleInlineContent
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case type, identifier, title, titleInlineContent, url
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(ReferenceIdentifier.self, forKey: .identifier)

        let urlPath = try values.decode(String.self, forKey: .url)

        if let formattedTitle = try values.decodeIfPresent([InlineContent].self, forKey: .titleInlineContent) {
            titleInlineContent = formattedTitle
            title = try values.decodeIfPresent(String.self, forKey: .title) ?? formattedTitle.plainText
        } else if let plainTextTitle = try values.decodeIfPresent(String.self, forKey: .title) {
            titleInlineContent = [.text(plainTextTitle)]
            title = plainTextTitle
        } else {
            titleInlineContent = [.text(urlPath)]
            title = urlPath
        }

        url = urlPath
    }
}
