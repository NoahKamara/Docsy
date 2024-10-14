//
//  NavigatorIndex.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import OSLog

public class NavigatorIndex {
    static let logger = Logger.docsy("Index")

    public init() {
        self.tree = NavigatorTree()
    }

    /// The tree of the index
    public let tree: NavigatorTree
}

public extension NavigatorIndex {
    
}
