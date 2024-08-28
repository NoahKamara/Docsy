import Foundation

/// A kind of a REST request parameter.
///
/// Parameter sections might describe parameters used in
/// the URL query, the URL path, HTTP headers, or a multi-part HTTP body.
public enum RESTParameterSource: String, Codable {
    /// A named URL query parameter, for example, `?category=90s`.
    case query
    /// A named URL path parameter, for example, `/artists/MyArtist`.
    case path
    /// An HTTP header sent with the request, for example, `Authorization: MyCredentials`.
    case header
    /// An HTTP cookie sent with the request.
    case cookie
}

/// A section that contains a list of REST parameters.
public struct RESTParametersSection: SectionProtocol, Equatable {
    public var kind: Kind = .restParameters
    /// The title for the section.
    public let title: String
    /// The list of REST parameters.
    public let items: [RenderProperty]
    /// The kind of listed parameters.
    public let source: RESTParameterSource
    
    /// Creates a new REST parameters section.
    /// - Parameters:
    ///   - title: The title for the section.
    ///   - items: The list of REST parameters.
    ///   - source: The kind of listed parameters.
    public init(title: String, items: [RenderProperty], source: RESTParameterSource) {
        self.title = title
        self.items = items
        self.source = source
    }
}
