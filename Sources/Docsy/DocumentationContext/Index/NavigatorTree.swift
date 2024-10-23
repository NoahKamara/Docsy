//
//  NavigatorTree.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Observation

// MARK: Root

public extension NavigatorIndex {
    @Observable
    class BundlesNode: Node {
        public var isEmpty: Bool {
            access(keyPath: \.bundles.count)
            return bundles.isEmpty
        }

        private var bundles: [BundleNode] = []

        override public var children: [NavigatorIndex.Node]! {
            access(keyPath: \.bundles)
            return bundles
        }

        init(title: String, bundles: [BundleNode]) {
            self.bundles = bundles
            super.init(
                title: title,
                children: [],
                reference: nil,
                type: .root
            )
        }

        @MainActor
        func insertBundle(_ bundle: BundleNode, at offset: Int) {
            if let existingBundleIndex = bundles.firstIndex(where: { $0.identifier == bundle.identifier }) {
                withMutation(keyPath: \.bundles[existingBundleIndex]) {
                    bundles[existingBundleIndex] = bundle
                }
            } else {
                withMutation(keyPath: \.bundles) {
                    bundles.append(bundle)
                }
            }
        }

        @MainActor
        func removeBundle(_ identifier: BundleIdentifier) {
            withMutation(keyPath: \.bundles) {
                _ = bundles.removeAll(where: { $0.identifier == identifier })
            }
        }
    }

    @Observable
    class RootNode: Node {
        public var nodes: [NavigatorIndex.Node]

        override public var children: [NavigatorIndex.Node]! {
            access(keyPath: \.nodes)
            return nodes
        }

        public init(nodes: [NavigatorIndex.Node]) {
            self.nodes = nodes
            super.init(title: "", children: nil, reference: nil, type: .root)
        }
    }

    /// The tree of a ``NavigatorIndex``
    @Observable
    class NavigatorTree: Node {
        public let root: RootNode

        public var isEmpty: Bool {
            access(keyPath: \.root.children?.isEmpty)
            return root.children?.isEmpty != false
        }

        override public var children: [NavigatorIndex.Node]! {
            access(keyPath: \.root.children)
            return root.children
        }

        init(rootNodes: [Node] = []) {
            self.root = RootNode(nodes: rootNodes)
            super.init(
                title: "",
                children: [],
                reference: nil,
                type: .root
            )
        }
    }
}

// MARK: Tree Representation

extension NavigatorIndex.Node {
    func treeLines(prefix: String = "", isLast: Bool = true) -> [String] {
        var line = prefix

        if prefix != "" {
            line += isLast ? "╰─" : "├─"
        }

        line += "[\(type.rawValue)] \(title)"

        return if let children {
            children.enumerated().reduce(into: [line]) { result, element in
                let (index, child) = element
                let newPrefix = prefix + (isLast ? "    " : "│   ")
                result += child.treeLines(prefix: newPrefix, isLast: index == children.count - 1)
            }
        } else {
            [line]
        }
    }

    /// returns a tree representation of this nide
    public func dumpTree() -> String {
        treeLines().joined(separator: "\n")
    }
}
