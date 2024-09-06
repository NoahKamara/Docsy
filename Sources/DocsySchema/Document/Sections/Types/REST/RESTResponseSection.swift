import Foundation

/// A section that displays a list of REST responses.
public struct RESTResponseSection: SectionProtocol, Equatable {
    public var kind: Kind = .restResponses
    /// The title for the section.
    public let title: String
    /// The list of possible REST responses.
    public let items: [RESTResponse]
}

/// A REST response that includes the HTTP status, reason,
/// and the MIME type encoding of the response body.
///
/// If the response is a decodable object, a declaration-style `type` property
/// describes the expected type and can provide an optional link to the expected
/// documentation symbol.
public struct RESTResponse: Decodable, Equatable {
    /// The HTTP status code for the response.
    public let status: UInt
    /// An optional plain-text reason for the response.
    public let reason: String?
    /// An optional response MIME content-type.
    public let mimeType: String?
    /// A type declaration of the response's content.
    public let type: [DeclarationSection.Token]
    /// Response details, if any.
    public let content: [BlockContent]?

    /// Creates a new REST response section.
    /// - Parameters:
    ///   - status: The HTTP status code for the response.
    ///   - reason: An optional plain-text reason for the response.
    ///   - mimeType: An optional response MIME content-type.
    ///   - type: A type declaration of the response's content.
    ///   - content: Response details, if any.
    public init(
        status: UInt,
        reason: String?,
        mimeType: String?,
        type: [DeclarationSection.Token],
        content: [BlockContent]?
    ) {
        self.status = status
        self.reason = reason
        self.mimeType = mimeType
        self.type = type
        self.content = content
    }

    enum CodingKeys: CodingKey {
        case status
        case reason
        case mimeType
        case type
        case content
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(UInt.self, forKey: .status)
        self.reason = try container.decodeIfPresent(String.self, forKey: .reason)
        self.mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        self.type = try container.decode([DeclarationSection.Token].self, forKey: .type)
        self.content = try container.decodeIfPresent([BlockContent].self, forKey: .content)
    }
}
