//
//  File.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// A section of documentation content.
public struct ContentSection: SectionProtocol, Equatable {
    public let kind: SectionKind

    /// Arbitrary content for this section.
    public var content: [BlockContent]

    public init(kind: SectionKind, content: [BlockContent]) {
        self.kind = kind
        self.content = content
    }
}
