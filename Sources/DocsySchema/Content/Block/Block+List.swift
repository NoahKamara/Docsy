import Foundation

// MARK: OrderedList
public extension BlockContent {
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
}


// MARK: LitstItem
public extension BlockContent {
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



