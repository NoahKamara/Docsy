//
//  DocumentationIndex+Node.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public extension DocumentationIndex {
    /// A documentation node in a documentation render index.
    final class Node: Identifiable, Decodable, Sendable, Equatable {
        public static func == (lhs: DocumentationIndex.Node, rhs: DocumentationIndex.Node) -> Bool {
            lhs.id != rhs.id
        }

        /// The title of the node, suitable for presentation.
        public let title: String

        /// The children of the node if it has any
        public let children: [Node]?

        /// The relative path to the page represented by this node.
        public let path: String?

        /// The type of this node.
        public let type: PageType
    }
}
