//
//  Block+List.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public extension BlockContent {
    // MARK: OrderedList

    /// A list that contains ordered items.
    struct OrderedList: BlockContentProtocol {
        /// The items in this list.
        public var items: [ListItem]
        /// The starting index for items in this list.
        public var startIndex: UInt

        /// Creates a new ordered list with the given items.
        public init(items: [ListItem], startIndex: UInt = 1) {
            self.items = items
            self.startIndex = startIndex
        }

        init(from container: Container) throws {
            try self.init(
                items: container.decode([ListItem].self, forKey: .items),
                startIndex: container.decodeIfPresent(UInt.self, forKey: .start) ?? 1
            )
        }
    }

    // MARK: Unordered

    /// A list that contains unordered items.
    struct UnorderedList: Equatable, Sendable {
        /// The items in this list.
        public var items: [ListItem]

        /// Creates a new unordered list with the given items.
        public init(items: [ListItem]) {
            self.items = items
        }
    }

    // MARK: ListItem

    /// An item in a list.
    struct ListItem: Schema {
        /// The item content.
        public var content: [BlockContent]
        /// If this list item is a task list item, whether the task should be checked off.
        public var checked: Bool?

        /// Creates a new list item with the given content.
        public init(content: [BlockContent], checked: Bool? = nil) {
            self.content = content
            self.checked = checked
        }
    }
}

public extension BlockContent {
    // MARK: TermList

    /// A list of terms.
    struct TermList: Schema {
        /// The items in this list.
        public var items: [TermListItem]

        /// Creates a new term list with the given items.
        public init(items: [TermListItem]) {
            self.items = items
        }
    }

    // MARK: TermList Item

    /// A term definition.
    ///
    /// Includes a named term and its definition, that look like:
    ///  - term: "Generic Types"
    ///  - definition: "Custom classes, structures, and enumerations that can
    ///    work with any type, in a similar way to `Array` and `Dictionary`."
    ///
    /// The term contains a list of inline elements to allow formatting while,
    /// the definition can be any free-form content including images, paragraphs, tables, etc.
    struct TermListItem: Schema {
        /// A term rendered as content.
        public struct Term: Schema {
            /// The term content.
            public let inlineContent: [InlineContent]
        }

        /// A definition rendered as a list of block-content elements.
        public struct Definition: Schema {
            /// The definition content.
            public let content: [BlockContent]
        }

        /// The term in the term-list item.
        public let term: Term
        /// The definition in the term-list item.
        public let definition: Definition
    }
}
