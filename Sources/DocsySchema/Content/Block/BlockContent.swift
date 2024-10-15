//
//  BlockContent.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

// MARK: Decoding

public extension BlockContent {
    internal enum CodingKeys: CodingKey {
        case type
        case inlineContent, content, caption, style, name, syntax, code, level, text, items, media, runtimePreview, anchor, summary, example, metadata, start
        case request, response
        case header, rows
        case numberOfColumns, columns
        case tabs
        case identifier
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(BlockType.self, forKey: .type)

        self = switch type {
        case .paragraph: try .paragraph(.init(from: container))
        case .aside: try .aside(.init(from: container))
        case .codeListing: try .codeListing(.init(from: container))
        case .heading: try .heading(.init(from: container))

        // MARK: Lists
        case .orderedList: try .orderedList(.init(from: container))
        case .unorderedList: try .unorderedList(.init(items: container.decode([ListItem].self, forKey: .items)))
        case .termList: try .termList(.init(items: container.decode([TermListItem].self, forKey: .items)))
        case .table:
            // Defer to Table's own Codable implemenatation to parse `extendedData` properly.
            try .table(.init(from: decoder))
//        case .row: try .row(
//                Row(
//                    numberOfColumns: container.decode(Int.self, forKey: .numberOfColumns),
//                    columns: container.decode([Row.Column].self, forKey: .columns)
//                )
//            )
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
        case .thematicBreak: .thematicBreak
        default: throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "Unknown type \(type.rawValue)"))
        }
    }

    enum BlockType: String, Codable {
        case paragraph, aside, codeListing, heading, orderedList, unorderedList, step, endpointExample, dictionaryExample, table, termList, row, small, tabNavigator, links, video, thematicBreak
    }

    var type: BlockType {
        switch self {
        case .paragraph: .paragraph
        case .aside: .aside
        case .codeListing: .codeListing
        case .heading: .heading
        case .orderedList: .orderedList
        case .unorderedList: .unorderedList
        case .termList: .termList
        case .table: .table
//                    case .step: return .step
//                    case .endpointExample: return .endpointExample
//                    case .dictionaryExample: return .dictionaryExample
//        case .row: .row
//        case .small: .small
//        case .tabNavigator: .tabNavigator
//        case .links: .links
//        case .video: .video
        case .thematicBreak: .thematicBreak
//        default: fatalError("unknown RenderBlockContent case in type property \(self)")
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

// MARK: CodeListing

public extension BlockContent {
    /// A block of sample code.
    struct CodeListing: BlockContentProtocol {
        /// The language to use for syntax highlighting, if given.
        public var syntax: SourceLanguage?
        /// The lines of code inside the code block.
        public var code: [String]
        /// Additional metadata for this code block.
        public var metadata: ContentMetadata?

        /// Make a new `CodeListing` with the given data.
        public init(
            syntax: SourceLanguage?,
            code: [String],
            metadata: ContentMetadata?
        ) {
            self.syntax = syntax
            self.code = code
            self.metadata = metadata
        }

        init(from container: Container) throws {
            try self.init(
                syntax: container.decodeIfPresent(String.self, forKey: .syntax).map(SourceLanguage.init(name:)),
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

///// A step in a multi-step tutorial.
// public struct TutorialStep: Equatable {
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
// }
//
///// A REST endpoint example that includes a request and the expected response.
// public struct EndpointExample: Equatable {
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
// }
//
///// An example that contains a sample code block.
// public struct DictionaryExample: Equatable {
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
// }
//

//
///// A row in a grid-based layout system that describes a collection of columns.
// public struct Row: Codable, Equatable {
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
// }

///// A paragraph of small print content that should be rendered in a small font.
/////
///// Small is based on HTML's `<small>` tag and could contain content like legal,
///// license, or copyright text.
// public struct Small: Codable, Equatable {
//    /// The inline content that should be rendered.
//    public let inlineContent: [InlineContent]
// }
//
///// A collection of content that should be rendered in a tab-based layout.
// public struct TabNavigator: Codable, Equatable {
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
// }
//
///// A collection of authored links that should be rendered in a similar style
///// to links in an on-page Topics section.
// public struct Links: Codable, Equatable {
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
// }
//
///// A video with an optional caption.
// public struct Video: Codable, Equatable {
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
