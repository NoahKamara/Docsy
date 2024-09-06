//
//  DecodingError+Described.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

extension DecodingError: DescribedError {
    public var errorDescription: String {
        switch self {
        case .dataCorrupted(let context):
            "dataCorruted(\(context.codingPath.errorDescription)): \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            "keyNotFound(\(key.errorDescription), \(context.codingPath.errorDescription)): \(context.debugDescription)"
        case .typeMismatch(let type, let context):
            "typeMismatch(\(type), \(context.codingPath.errorDescription)) \(context.debugDescription)"
        case .valueNotFound(let type, let context):
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
