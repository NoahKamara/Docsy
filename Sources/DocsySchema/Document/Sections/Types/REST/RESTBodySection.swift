import Foundation

/// A section that contains a REST request-body details.
public struct RESTBodySection: SectionProtocol, Equatable {
    public var kind: Kind = .restBody
    /// A title for the section.
    public let title: String

    /// Content encoding MIME type for the request body.
    public let mimeType: String

    /// A declaration that describes the body content.
    public let bodyContentType: [DeclarationSection.Token]

    /// Details about the request body, if available.
    public let content: [BlockContent]?

    /// A list of request parameters, if applicable.
    ///
    /// If the body content is `multipart/form-data` encoded, it contains a list
    /// of parameters. Each of these parameters is a ``RESTParameter``
    /// and it has its own value-content encoding, name, type, and description.
    public let parameters: [RenderProperty]?
}
