import Foundation

public struct ReferenceIdentifier: Codable, Hashable, Equatable, Sendable {
    /// The wrapped string identifier.
    public let identifier: String

    public init(_ identifier: String) {
        self.identifier = identifier
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        identifier = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifier)
    }

    private enum CodingKeys: CodingKey {
        case identifier
    }
}
