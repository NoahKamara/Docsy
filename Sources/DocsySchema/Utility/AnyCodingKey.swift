//
//  AnyCodingKey.swift
//  Docsy
//
//  Created by Noah Kamara on 26.08.24.
//

import Foundation

public struct AnyCodingKey: CodingKey {
    public let stringValue: String
    public var intValue: Int? { nil }
    public init?(intValue _: Int) {
        return nil
    }

    public init(stringValue: String) {
        self.stringValue = stringValue
    }
}
