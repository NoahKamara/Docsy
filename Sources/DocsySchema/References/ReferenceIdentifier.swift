import Foundation

public struct ReferenceIdentifier: Codable, Hashable, Equatable, Sendable {
    /// The wrapped string identifier.
    public let identifier: String

    public init(_ identifier: String) {
        self.identifier = identifier
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.identifier = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifier)
    }

    private enum CodingKeys: CodingKey {
        case identifier
    }
}

extension ReferenceIdentifier: CodingKeyRepresentable {
    var codingKey: any CodingKey { AnyCodingKey(stringValue: identifier) }
    init(from codingKey: any CodingKey) {
        self.init(codingKey.stringValue)
    }
}

protocol CodingKeyRepresentable {
    var codingKey: CodingKey { get }
    init(from codingKey: CodingKey)
}

public struct WrappedCodingKey<T>: CodingKey {
    public let stringValue: String
    public var intValue: Int? { nil }
    public init?(intValue _: Int) {
        nil
    }

    public init(stringValue: String) {
        self.stringValue = stringValue
    }
}
