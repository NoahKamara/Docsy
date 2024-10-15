//
//  Hierarchy+Landmark.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public extension Document.Hierarchy {
    struct Landmark: Codable, Equatable, Sendable {
        /// The kind of a landmark.
        public enum Kind: String, Codable, Sendable {
            /// A landmark at the start of a task.
            case task
            /// A landmark at the start of an assessment.
            case assessment
            /// A landmark to a heading in the content.
            case heading
        }

        /// The topic reference for the landmark.
        public let reference: ReferenceIdentifier

        /// The kind of landmark.
        public let kind: Kind
    }
}
