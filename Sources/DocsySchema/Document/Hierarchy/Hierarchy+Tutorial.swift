//
//  Hierarchy+Tutorial.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

public extension Document.Hierarchy {
    struct Tutorial: Codable, Equatable, Sendable {
        /// The topic reference.
        public let reference: ReferenceIdentifier

        /// The landmarks on the page.
        public let landmarks: [Landmark] = []

        private enum CodingKeys: String, CodingKey {
            case reference
            case landmarks = "sections"
        }
    }
}
