import Foundation




// MARK: Decoding
extension BlockContent {
    enum CodingKeys: CodingKey {
        case type
        case inlineContent, content, caption, style, name, syntax, code, level, text, items, media, runtimePreview, anchor, summary, example, metadata, start
        case request, response
        case header, rows
        case numberOfColumns, columns
        case tabs
        case identifier
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(BlockType.self, forKey: .type)

        self = switch type {
        case .paragraph: try .paragraph(.init(from: container))
        case .aside: try .aside(.init(from: container))
        case .codeListing: try .codeListing(.init(from: container))
        case .heading: try .heading(.init(from: container))
        case .orderedList: try .orderedList(.init(from: container))
            //        case .unorderedList:
            //            self = try .unorderedList(.init(items: container.decode([ListItem].self, forKey: .items)))
            //        case .step:
            //            self = try .step(.init(content: container.decode([RenderBlockContent].self, forKey: .content), caption: container.decodeIfPresent([RenderBlockContent].self, forKey: .caption) ?? [], media: container.decode(RenderReferenceIdentifier?.self, forKey: .media), code: container.decode(RenderReferenceIdentifier?.self, forKey: .code), runtimePreview: container.decode(RenderReferenceIdentifier?.self, forKey: .runtimePreview)))
            //        case .endpointExample:
            //            self = try .endpointExample(.init(
            //                summary: container.decodeIfPresent([RenderBlockContent].self, forKey: .summary),
            //                request: container.decode(CodeExample.self, forKey: .request),
            //                response: container.decode(CodeExample.self, forKey: .response)
            //            ))
            //        case .dictionaryExample:
            //            self = try .dictionaryExample(.init(summary: container.decodeIfPresent([RenderBlockContent].self, forKey: .summary), example: container.decode(CodeExample.self, forKey: .example)))
            //        case .table:
            //            // Defer to Table's own Codable implemenatation to parse `extendedData` properly.
            //            self = try .table(.init(from: decoder))
            //        case .termList:
            //            self = try .termList(.init(items: container.decode([TermListItem].self, forKey: .items)))
            //        case .row:
            //            self = try .row(
            //                Row(
            //                    numberOfColumns: container.decode(Int.self, forKey: .numberOfColumns),
            //                    columns: container.decode([Row.Column].self, forKey: .columns)
            //                )
            //            )
            //        case .small:
            //            self = try .small(
            //                Small(inlineContent: container.decode([InlineContent].self, forKey: .inlineContent))
            //            )
            //        case .tabNavigator:
            //            self = try .tabNavigator(
            //                TabNavigator(
            //                    tabs: container.decode([TabNavigator.Tab].self, forKey: .tabs)
            //                )
            //            )
            //        case .links:
            //            self = try .links(
            //                Links(
            //                    style: container.decode(Links.Style.self, forKey: .style),
            //                    items: container.decode([String].self, forKey: .items)
            //                )
            //            )
            //        case .video:
            //            self = try .video(
            //                Video(
            //                    identifier: container.decode(RenderReferenceIdentifier.self, forKey: .identifier),
            //                    metadata: container.decodeIfPresent(RenderContentMetadata.self, forKey: .metadata)
            //                )
            //            )
            //        case .thematicBreak:
            //            self = .thematicBreak
        default: throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "Unknown type \(type.rawValue)"))

        }
    }

    private enum BlockType: String, Codable {
        case paragraph, aside, codeListing, heading, orderedList, unorderedList, step, endpointExample, dictionaryExample, table, termList, row, small, tabNavigator, links, video, thematicBreak
    }

    private var type: BlockType {
        switch self {
        case .paragraph: return .paragraph
        case .aside: return .aside
        case .codeListing: return .codeListing
        case .heading: return .heading
//                    case .orderedList: return .orderedList
            //        case .unorderedList: return .unorderedList
            //        case .step: return .step
            //        case .endpointExample: return .endpointExample
            //        case .dictionaryExample: return .dictionaryExample
            //        case .table: return .table
            //        case .termList: return .termList
            //        case .row: return .row
            //        case .small: return .small
            //        case .tabNavigator: return .tabNavigator
            //        case .links: return .links
            //        case .video: return .video
            //        case .thematicBreak: return .thematicBreak
        default: fatalError("unknown RenderBlockContent case in type property")
        }
    }
}


// MARK: Content Protocol
protocol BlockContentProtocol: Equatable, Sendable {
    typealias Container = KeyedDecodingContainer<BlockContent.CodingKeys>
    init(from container: Container) throws
}


// MARK: Paragraph
public extension BlockContent {
    /// A paragraph of content.
    struct Paragraph: BlockContentProtocol {
        /// The content inside the paragraph.
        public var inlineContent: [InlineContent]

        /// Creates a new paragraph with the given content.
        public init(inlineContent: [InlineContent]) {
            self.inlineContent = inlineContent
        }

        init(from container: Container) throws {
            let inlineContent = try container.decode([InlineContent].self, forKey: .inlineContent)
            self.init(inlineContent: inlineContent)
        }
    }
}


// MARK: Aside
public extension BlockContent {
    /// An aside block.
    struct Aside: Equatable, Sendable, BlockContentProtocol {
        /// An appropriate display name for this aside
        public var displayName: String {
            customName ?? style.displayName
        }

        /// The style of this aside block.
        let customName: String?

        /// The style of this aside block.
        public var style: AsideStyle

        /// The content inside this aside block.
        public var content: [BlockContent]

        public init(
            displayName: String? = nil,
            style: AsideStyle,
            content: [BlockContent]
        ) {
            self.customName = displayName
            self.style = style
            self.content = content
        }

        init(from container: Container) throws {
            let customName = try container.decodeIfPresent(String.self, forKey: .name)
            let style = try container.decode(AsideStyle.self, forKey: .style)
            let content = try container.decode([BlockContent].self, forKey: .content)

            self.init(
                displayName: customName,
                style: style,
                content: content
            )
        }
    }

    /// A type the describes an aside style.
    enum AsideStyle: Decodable, Equatable, Sendable {
        case known(Known)
        case unknown(_ rawValue: String)

        public var rawValue: String {
            switch self {
            case .known(let known): known.rawValue
            case .unknown(let rawValue): rawValue
            }
        }

        /// an appropriate display name for this style
        public var displayName: String {
            switch self {
            case .known(let known): known.displayName
            case .unknown(let rawValue):
                if rawValue.contains(where: \.isUppercase) {
                    // If any character is upper-cased, assume the content has
                    // specific casing and return the raw value.
                    rawValue
                } else {
                    rawValue.capitalized
                }
            }
        }

        public enum Known: String, Equatable, Sendable, CaseIterable {
            case note = "Note"
            case tip = "Tip"
            case important = "Important"
            case experiment = "Experiment"
            case warning = "Warning"
            case attention = "Attention"
            case author = "Author"
            case authors = "Authors"
            case bug = "Bug"
            case complexity = "Complexity"
            case copyright = "Copyright"
            case date = "Date"
            case invariant = "Invariant"
            case mutatingVariant = "MutatingVariant"
            case nonMutatingVariant = "NonMutatingVariant"
            case postcondition = "Postcondition"
            case precondition = "Precondition"
            case remark = "Remark"
            case requires = "Requires"
            case since = "Since"
            case toDo = "ToDo"
            case version = "Version"
            case `throws` = "Throws"
            case seeAlso = "SeeAlso"

            public var displayName: String {
                switch self {
                case .invariant: "Invariant"
                case .mutatingVariant: "Mutating Variant"
                case .nonMutatingVariant: "Non-Mutating Variant"
                case .toDo: "To Do"
                case .seeAlso: "See Also"
                default: rawValue
                }
            }
        }

        public enum OutputStyle {
            case note
            case tip
            case experiment
            case important
            case warning
        }

        /// The style of aside to use when rendering.
        public var renderKind: OutputStyle {
            switch self {
            case .known(let known):
                switch known {
                case .note: .note
                case .tip: .tip
                case .experiment: .experiment
                case .important: .important
                case .warning: .warning
                default: .note
                }
            case .unknown: .note
            }
        }

        /// Creates an aside style for the specified raw value.
        /// - Parameter rawValue: The heading text to use when rendering this style of aside.
        init(rawValue: String) {
            self = if let known = Known(rawValue: rawValue) {
                .known(known)
            } else {
                .unknown(rawValue)
            }
        }

        /// Creates an aside style by decoding the specified decoder.
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self.init(rawValue: rawValue)
        }
    }
}


// MARK: CodeListing
public extension BlockContent {

/// A block of sample code.
    struct CodeListing: BlockContentProtocol {
        /// The language to use for syntax highlighting, if given.
        public var syntax: String?
        /// The lines of code inside the code block.
        public var code: [String]
        /// Additional metadata for this code block.
        public var metadata: ContentMetadata?

        /// Make a new `CodeListing` with the given data.
        public init(
            syntax: String?,
            code: [String],
            metadata: ContentMetadata?
        ) {
            self.syntax = syntax
            self.code = code
            self.metadata = metadata
        }

        init(from container: Container) throws {
            try self.init(
                syntax: container.decodeIfPresent(String.self, forKey: .syntax),
                code: container.decode([String].self, forKey: .code),
                metadata: container.decodeIfPresent(ContentMetadata.self, forKey: .metadata)
            )
        }
    }
}


// MARK: Heading
public extension BlockContent {
    /// A heading with the given level.
    struct Heading: BlockContentProtocol {
        /// The level of the heading.
        /// > like HTML 1-6
        public var level: Int

        /// The text in the heading.
        public var text: String

        /// An optional anchor slug that can be used to link to the heading.
        public var anchor: String?

        /// Creates a new heading with the given data.
        public init(level: Int, text: String, anchor: String?) {
            self.level = level
            self.text = text
            self.anchor = anchor
        }

        init(from container: Container) throws {
            try self.init(
                level: container.decode(Int.self, forKey: .level),
                text: container.decode(String.self, forKey: .text),
                anchor: container.decodeIfPresent(String.self, forKey: .anchor)
            )
        }
    }
}



///// A list that contains unordered items.
//public struct UnorderedList: Equatable {
//    /// The items in this list.
//    public var items: [ListItem]
//
//    /// Creates a new unordered list with the given items.
//    public init(items: [ListItem]) {
//        self.items = items
//    }
//}
//
///// A step in a multi-step tutorial.
//public struct TutorialStep: Equatable {
//    /// The content inside this tutorial step.
//    public var content: [BlockContent]
//    /// The caption for the step.
//    public var caption: [BlockContent]
//    /// An optional media reference to accompany the step.
//    public var media: ReferenceIdentifier?
//    /// The source code file associated with this step.
//    public var code: ReferenceIdentifier?
//    /// A rendering of the tutorial step, if available.
//    public var runtimePreview: ReferenceIdentifier?
//
//    /// Creates a new tutorial step with the given items.
//    public init(content: [BlockContent], caption: [BlockContent], media: ReferenceIdentifier? = nil, code: ReferenceIdentifier? = nil, runtimePreview: ReferenceIdentifier? = nil) {
//        self.content = content
//        self.caption = caption
//        self.media = media
//        self.code = code
//        self.runtimePreview = runtimePreview
//    }
//}
//
///// A REST endpoint example that includes a request and the expected response.
//public struct EndpointExample: Equatable {
//    /// A summary of the example.
//    public var summary: [BlockContent]?
//    /// The request portion of the example.
//    public var request: CodeExample
//    /// The expected response for the given request.
//    public var response: CodeExample
//
//    /// Creates a new REST endpoint example with the given data.
//    public init(summary: [BlockContent]? = nil, request: CodeExample, response: CodeExample) {
//        self.summary = summary
//        self.request = request
//        self.response = response
//    }
//}
//
///// An example that contains a sample code block.
//public struct DictionaryExample: Equatable {
//    /// A summary of the sample code block.
//    public var summary: [BlockContent]?
//    /// The sample code for the example.
//    public var example: CodeExample
//
//    /// Creates a new example with the given data.
//    public init(summary: [BlockContent]? = nil, example: CodeExample) {
//        self.summary = summary
//        self.example = example
//    }
//}
//
///// A list of terms.
//public struct TermList: Equatable {
//    /// The items in this list.
//    public var items: [TermListItem]
//
//    /// Creates a new term list with the given items.
//    public init(items: [TermListItem]) {
//        self.items = items
//    }
//}
//
///// A table that contains a list of row data.
//public struct Table {
//    /// The style of header in this table.
//    public var header: HeaderType
//    /// The text alignment of each column in this table.
//    ///
//    /// A `nil` value for this property is the same as all the columns being
//    /// ``BlockContent/ColumnAlignment/unset``.
//    public var alignments: [ColumnAlignment]?
//    /// The rows in this table.
//    public var rows: [TableRow]
//    /// Any extended information that describes cells in this table.
//    public var extendedData: Set<TableCellExtendedData>
//    /// Additional metadata for this table, if present.
//    public var metadata: ContentMetadata?
//
//    /// Creates a new table with the given data.
//    ///
//    /// - Parameters:
//    ///   - header: The style of header in this table.
//    ///   - rawAlignments: The text alignment for each column in this table. If all the
//    ///     alignments are ``BlockContent/ColumnAlignment/unset``, the ``alignments``
//    ///     property will be set to `nil`.
//    ///   - rows: The cell data for this table.
//    ///   - extendedData: Any extended information that describes cells in this table.
//    ///   - metadata: Additional metadata for this table, if necessary.
//    public init(header: HeaderType, rawAlignments: [ColumnAlignment]? = nil, rows: [TableRow], extendedData: Set<TableCellExtendedData>, metadata: ContentMetadata? = nil) {
//        self.header = header
//        self.rows = rows
//        self.extendedData = extendedData
//        self.metadata = metadata
//        if let alignments = rawAlignments, !alignments.allSatisfy({ $0 == .unset }) {
//            self.alignments = alignments
//        }
//    }
//}
//


//
///// The table headers style.
//public enum HeaderType: String, Codable, Equatable {
//    /// The first row in the table contains column headers.
//    case row
//    /// The first column in the table contains row headers.
//    case column
//    /// Both the first row and column contain headers.
//    case both
//    /// The table doesn't contain headers.
//    case none
//}
//
///// The methods by which a table column can have its text aligned.
//public enum ColumnAlignment: String, Codable, Equatable {
//    /// Force text alignment to be left-justified.
//    case left
//    /// Force text alignment to be right-justified.
//    case right
//    /// Force text alignment to be centered.
//    case center
//    /// Leave text alignment to the default.
//    case unset
//}
//
///// A table row that contains a list of row cells.
//public struct TableRow: Codable, Equatable {
//    /// A list of rendering block elements.
//    public typealias Cell = [BlockContent]
//    /// The list of row cells.
//    public let cells: [Cell]
//
//    /// Creates a new table row.
//    /// - Parameter cells: The list of row cells to use.
//    public init(cells: [Cell]) {
//        self.cells = cells
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(cells)
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        cells = try container.decode([Cell].self)
//    }
//}
//
///// Extended data that may be applied to a table cell.
//public struct TableCellExtendedData: Equatable, Hashable {
//    /// The row coordinate for the cell described by this data.
//    public let rowIndex: Int
//    /// The column coordinate for the cell described by this data.
//    public let columnIndex: Int
//
//    /// The number of columns this cell spans over.
//    ///
//    /// A value of 1 is the default. A value of zero means that this cell is being "spanned
//    /// over" by a previous cell in this row. A value of greater than 1 means that this cell
//    /// "spans over" later cells in this row.
//    public let colspan: UInt
//
//    /// The number of rows this cell spans over.
//    ///
//    /// A value of 1 is the default. A value of zero means that this cell is being "spanned
//    /// over" by another cell in a previous row. A value of greater than one means that this
//    /// cell "spans over" other cells in later rows.
//    public let rowspan: UInt
//
//    public init(rowIndex: Int, columnIndex: Int,
//                colspan: UInt, rowspan: UInt) {
//        self.rowIndex = rowIndex
//        self.columnIndex = columnIndex
//        self.colspan = colspan
//        self.rowspan = rowspan
//    }
//}
//
///// A term definition.
/////
///// Includes a named term and its definition, that look like:
/////  - term: "Generic Types"
/////  - definition: "Custom classes, structures, and enumerations that can
/////    work with any type, in a similar way to `Array` and `Dictionary`."
/////
///// The term contains a list of inline elements to allow formatting while,
///// the definition can be any free-form content including images, paragraphs, tables, etc.
//public struct TermListItem: Codable, Equatable {
//    /// A term rendered as content.
//    public struct Term: Codable, Equatable {
//        /// The term content.
//        public let inlineContent: [InlineContent]
//    }
//    /// A definition rendered as a list of block-content elements.
//    public struct Definition: Codable, Equatable {
//        /// The definition content.
//        public let content: [BlockContent]
//    }
//
//    /// The term in the term-list item.
//    public let term: Term
//    /// The definition in the term-list item.
//    public let definition: Definition
//}
//
///// A row in a grid-based layout system that describes a collection of columns.
//public struct Row: Codable, Equatable {
//    /// The number of columns that should be rendered in this row.
//    ///
//    /// This may be different then the count of ``columns`` array. For example, there may be
//    /// individual columns that span multiple columns (specified with the column's
//    /// ``Column/size`` property) or the row could be not fully filled with columns.
//    public let numberOfColumns: Int
//
//    /// The columns that should be rendered in this row.
//    public let columns: [Column]
//
//    /// A column with a row in a grid-based layout system.
//    public struct Column: Codable, Equatable {
//        /// The number of columns in the parent row this column should span.
//        public let size: Int
//
//        /// The content that should be rendered in this column.
//        public let content: [BlockContent]
//    }
//}
//
///// A paragraph of small print content that should be rendered in a small font.
/////
///// Small is based on HTML's `<small>` tag and could contain content like legal,
///// license, or copyright text.
//public struct Small: Codable, Equatable {
//    /// The inline content that should be rendered.
//    public let inlineContent: [InlineContent]
//}
//
///// A collection of content that should be rendered in a tab-based layout.
//public struct TabNavigator: Codable, Equatable {
//    /// The tabs that make up this tab navigator.
//    public let tabs: [Tab]
//
//    /// A titled tab inside a tab-based layout container.
//    public struct Tab: Codable, Equatable {
//        /// The title that should be used to identify this tab.
//        public let title: String
//
//        /// The content that should be rendered in this tab.
//        public let content: [BlockContent]
//    }
//}
//
///// A collection of authored links that should be rendered in a similar style
///// to links in an on-page Topics section.
//public struct Links: Codable, Equatable {
//    /// A visual style for the links.
//    public enum Style: String, Codable, Equatable {
//        /// A list of the linked pages, including their full declaration and abstract.
//        case list
//
//        /// A grid of items based on the card image for the linked pages.
//        case compactGrid
//
//        /// A grid of items based on the card image for the linked pages.
//        ///
//        /// Unlike ``compactGrid``, this style includes the abstract for each page.
//        case detailedGrid
//    }
//
//    /// The style that should be used when rendering the link items.
//    public let style: Style
//
//    /// The topic render references for the pages that should be rendered in this links block.
//    public let items: [String]
//
//    /// Create a new links block with the given style and topic render references.
//    public init(style: BlockContent.Links.Style, items: [String]) {
//        self.style = style
//        self.items = items
//    }
//}
//
///// A video with an optional caption.
//public struct Video: Codable, Equatable {
//    /// A reference to the video media that should be rendered in this block.
//    public let identifier: ReferenceIdentifier
//
//    /// Any metadata associated with this video, like a caption.
//    public let metadata: ContentMetadata?
//
//    /// Create a new video with the given identifier and metadata.
//    public init(identifier: ReferenceIdentifier, metadata: ContentMetadata? = nil) {
//        self.identifier = identifier
//        self.metadata = metadata
//    }
//    }
