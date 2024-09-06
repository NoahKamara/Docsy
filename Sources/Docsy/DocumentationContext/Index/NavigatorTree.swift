//
//  NavigatorTree.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Observation

// MARK: Root

public extension NavigatorIndex {
    /// The tree of a ``NavigatorIndex``
    @Observable
    class NavigatorTree: Node {
        public var availableLanguages: Set<SourceLanguage> {
            access(keyPath: \.nodes)
            return nodes.values.map(\.availableLanguages).reduce(Set()) {
                $0.union($1)
            }
        }

        public var isEmpty: Bool {
            access(keyPath: \.nodes.count)
            return nodes.isEmpty
        }

        private var nodes: [BundleIdentifier: BundleNode] = [:]

        override public var children: [NavigatorIndex.Node]! {
            access(keyPath: \.nodes)
            return Array(nodes.values)
        }

        init() {
            super.init(
                title: "Root",
                children: [],
                reference: nil,
                type: .root
            )
        }

        @MainActor
        func insertBundle(_ bundle: BundleNode) {
            withMutation(keyPath: \.nodes[bundle.identifier]) {
                nodes[bundle.identifier] = bundle
            }
        }

        @MainActor
        func removeBundle(_ identifier: BundleIdentifier) {
            withMutation(keyPath: \.nodes[identifier]) {
                _ = nodes.removeValue(forKey: identifier)
            }
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
