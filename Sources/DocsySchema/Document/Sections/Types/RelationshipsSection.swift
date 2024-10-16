//
//  RelationshipsSection.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// A section that contains a list of symbol relationships of the same kind.
public struct RelationshipsSection: SectionProtocol, Equatable {
    public let kind: Kind = .relationships

    /// A title for the section.
    public let title: String

    /// A list of references to the symbols that are related to the symbol.
    public let identifiers: [String]

    /// The type of relationship, e.g., "Conforms To".
    public let type: String

    /// Creates a new relationships section.
    /// - Parameters:
    ///   - type: The type of relationships in that section, for example, "Conforms To".
    ///   - title: The title for this section.
    ///   - identifiers: The list of related symbol references.
    public init(type: String, title: String, identifiers: [String]) {
        self.type = type
        self.title = title
        self.identifiers = identifiers
    }

    enum CodingKeys: CodingKey {
        case kind
        case title
        case identifiers
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.title = try container.decode(String.self, forKey: .title)
        self.identifiers = try container.decode([String].self, forKey: .identifiers)
    }
}
