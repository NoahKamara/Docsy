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
        public var rootNodes: [Node]
        
        public override var children: [NavigatorIndex.Node]? { rootNodes }
        
        init() {
            self.rootNodes = []
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
