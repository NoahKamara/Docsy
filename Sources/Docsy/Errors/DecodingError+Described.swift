
import Foundation

extension DecodingError: DescribedError {
    public var errorDescription: String {
        switch self {
        case let .dataCorrupted(context):
            "dataCorruted(\(context.codingPath.errorDescription)): \(context.debugDescription)"
        case let .keyNotFound(key, context):
            "keyNotFound(\(key.errorDescription), \(context.codingPath.errorDescription)): \(context.debugDescription)"
        case let .typeMismatch(type, context):
            "typeMismatch(\(type), \(context.codingPath.errorDescription)) \(context.debugDescription)"
        case let .valueNotFound(type, context):
            "valueNotFound(\(type), \(context.codingPath.errorDescription)): \(context.debugDescription)"
        @unknown default:
            "unknown(\(self))"
        }
    }
}

extension CodingKey {
    var errorDescription: String {
        if let intValue {
            "[\(intValue)]"
        } else {
            stringValue
        }
    }
}

extension [any CodingKey] {
    var errorDescription: String {
        if isEmpty {
            "."
        } else {
            map(\.errorDescription).joined(separator: ".")
        }
    }
}
