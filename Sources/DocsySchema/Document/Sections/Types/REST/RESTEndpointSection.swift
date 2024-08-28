import Foundation

/// A kind of a REST request endpoint.
///
/// Endpoints can describe either a production or sandbox URL.
public enum RESTEndpointType: String, Codable {
    /// A production endpoint.
    case production
    /// A sandbox endpoint used for testing.
    case sandbox
}

/// A section that contains a REST API endpoint.
///
/// This section is similar to ``DeclarationSection`` for symbols and
/// describes a tokenized endpoint for a REST API. The token list starts with
/// an HTTP method token followed by tokens for the complete endpoint URL. Any path
/// components that are dynamic instead of fixed are represented with a parameter name
/// enclosed in curly brackets.
///
/// A complete token representation for the endpoint `GET https://www.example.com/api/artists/{id}`
/// is (the token kind is in brackets):
///  - (method) `GET`
///  - (baseURL) `https://www.example.com`
///  - (path) `/api/artists/`
///  - (parameter) `{id}`
public struct RESTEndpointSection: SectionProtocol, Equatable {
    public var kind: Kind = .restEndpoint
    /// A single token in a REST endpoint.
    public struct Token: Codable, Equatable {
        /// The kind of REST endpoint token.
        public enum Kind: String, Codable {
            case method, baseURL, path, parameter, text
        }
        
        /// The endpoint specific token kind.
        public let kind: Kind
        /// The plain text of the token.
        public let text: String
    }
    
    /// The title for the section.
    public let title: String
    
    /// The list of tokens.
    public let tokens: [Token]
}
