//
//  Hierarchy+Chapter.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public extension Document.Hierarchy {
    struct Chapter: Codable, Equatable, Sendable {
        /// The topic reference for the chapter.
        public let reference: ReferenceIdentifier

        /// The tutorials in the chapter.
        public let tutorials: [Tutorial]

        enum CodingKeys: String, CodingKey {
            case reference
            // Both "tutorials" and "projects" correspond to the
            // same `tutorials` property for legacy reasons.
            case tutorials, projects
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.reference = try container.decode(ReferenceIdentifier.self, forKey: .reference)
            // Decode using the new key if its present, otherwise decode using the previous key
            let tutorialsKey = container.contains(.tutorials) ? CodingKeys.tutorials : CodingKeys.projects
            self.tutorials = try container.decode([Tutorial].self, forKey: tutorialsKey)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(reference, forKey: .reference)
            try container.encode(tutorials, forKey: .projects) // Encode using the previous key for compatibility
        }
    }
}
