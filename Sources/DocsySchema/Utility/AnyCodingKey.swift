//
//  AnyCodingKey.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public struct AnyCodingKey: CodingKey {
    public let stringValue: String
    public var intValue: Int? { nil }
    public init?(intValue _: Int) {
        nil
    }

    public init(stringValue: String) {
        self.stringValue = stringValue
    }
}
