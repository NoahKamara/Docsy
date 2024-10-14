//
//  NavigatorTree+Node.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Observation



public extension NavigatorIndex {
    // MARK: Node
    
    /// A Node in a ``NavigatorIndex``
    @Observable
    class Node: Identifiable {
        /// The title of the node, suitable for presentation.
        public let title: String

        /// The children of the node if it has any
        public private(set) var children: [Node]?

        /// The relative path to the page represented by this node.
        public let reference: TopicReference?

        /// The type of this node.
        public let type: PageType

        public init(title: String, children: [Node]?, reference: TopicReference?, type: PageType) {
            self.title = title
            self.children = children
            self.reference = reference
            self.type = type
        }

        convenience init(resolving node: DocumentationIndex.Node, at rootReference: TopicReference) {
            if let path = node.path {
                let reference = rootReference.appendingPath(path)

                self.init(
                    title: node.title,
                    children: node.children?.map { Node(resolving: $0, at: rootReference) },
                    reference: reference,
                    type: node.type
                )
            } else {
                if node.children?.isEmpty == false {
                    print("WARNING: Node without reference may not have children")
                }
                self.init(
                    title: node.title,
                    children: nil,
                    reference: nil,
                    type: node.type
                )
            }
        }

//        /// Unloads the bundle's index from this instance by removing it from the tree
//        /// - Parameters:
//        ///   - bundle: A Bundle that was provided by the dataProvider
//        ///   - dataProvider: A provider of documentation data
//        @MainActor
//        func unload(bundle: DocumentationBundle) {
//            Self.logger.debug("[\(bundle.identifier)] unlodaing")
//            tree.removeBundle(bundle.identifier)
//        }
    }
}

// MARK: LanguageGroup Node

public extension NavigatorIndex {
    /// A ``Node`` representing a source code language.
    ///
    /// > See A ``BundleNode`` for more info
    final class LanguageGroup: Node {
        public let language: SourceLanguage

        init(_ language: SourceLanguage, children: [NavigatorIndex.Node]? = nil) {
            self.language = language
            super.init(
                title: language.name,
                children: children,
                reference: nil,
                type: .languageGroup
            )
        }
    }
}
