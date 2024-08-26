//
//  File.swift
//  Docsy
//
//  Created by Noah Kamara on 26.08.24.
//

import Foundation

struct AnyCodingKey: CodingKey {
    public let stringValue: String
    public var intValue: Int? { nil }
    public init?(intValue: Int) {
        return nil
    }

    public init(stringValue: String) {
        self.stringValue = stringValue
    }
}
