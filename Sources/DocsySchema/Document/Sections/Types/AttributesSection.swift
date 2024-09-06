import Foundation

/// A section that contains a list of attributes.
public struct AttributesSection: SectionProtocol, Equatable {
    public var kind: Kind = .attributes
    /// The section title.
    public let title: String
    /// The list of attributes in this section.
    public let attributes: [RenderAttribute]?

    /// The list of keys you use to encode or decode the section data.
    public enum CodingKeys: String, CodingKey {
        case kind, title, attributes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.attributes = try container.decodeIfPresent([RenderAttribute].self, forKey: .attributes)
    }
}

/// A single renderable attribute.
public enum RenderAttribute: Decodable, Equatable {
    /// The list of keys to use to encode/decode the attribute.
    public enum CodingKeys: CodingKey, Hashable {
        case title, value, values, kind
    }

    /// A list of the plain-text names of supported attributes.
    public enum Kind: String, Codable {
        case `default`, minimum, minimumExclusive, maximum, maximumExclusive, minimumLength, maximumLength, allowedValues, allowedTypes
    }

    /// A default value, for example `none`.
    case `default`(String)
    /// A minimum value, for example `1.0`.
    case minimum(String)
    /// A minimum value (excluding the given one) for example `1.0`.
    case minimumExclusive(String)
    /// A maximum value, for example `10.0`.
    case maximum(String)
    /// A maximum value (excluding the given one), for example `10.0`.
    case maximumExclusive(String)
    /// A minimum allowed length of a string.
    case minimumLength(String)
    /// A maximum allowed length of a string.
    case maximumLength(String)
    /// A list of allowed values, for example `none`, `some`, and `all`.
    case allowedValues([String])
    /// A list of allowed type declarations for the value being described,
    /// for example `String`, `Int`, and `Double`.
    case allowedTypes([[DeclarationSection.Token]])

    /// A title for this attribute.
    var title: String {
        switch self {
        case .default: "Default value"
        case .minimum: "Minimum"
        case .minimumExclusive: "Minimum"
        case .maximum: "Maximum"
        case .maximumExclusive: "Maximum"
        case .minimumLength: "Minimum length"
        case .maximumLength: "Maximum length"
        case .allowedValues: "Possible Values"
        case .allowedTypes: "Possible Types"
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        switch try container.decode(Kind.self, forKey: .kind) {
        case .default:
            self = try .default(container.decode(String.self, forKey: .value))
        case .minimum:
            self = try .minimum(container.decode(String.self, forKey: .value))
        case .minimumExclusive:
            self = try .minimumExclusive(container.decode(String.self, forKey: .value))
        case .maximum:
            self = try .maximum(container.decode(String.self, forKey: .value))
        case .maximumExclusive:
            self = try .maximumExclusive(container.decode(String.self, forKey: .value))
        case .minimumLength:
            self = try .minimumLength(container.decode(String.self, forKey: .value))
        case .maximumLength:
            self = try .maximumLength(container.decode(String.self, forKey: .value))
        case .allowedValues:
            self = try .allowedValues(container.decode([String].self, forKey: .values))
        case .allowedTypes:
            self = try .allowedTypes(container.decode([[DeclarationSection.Token]].self, forKey: .values))
        }
    }
}
