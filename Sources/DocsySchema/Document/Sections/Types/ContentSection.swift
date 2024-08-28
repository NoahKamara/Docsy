////import Markdown
//
//public typealias BlockContent = String

/// A block content element.
public enum BlockContent: Decodable, Equatable, Sendable {
    /// A paragraph of content.
    case paragraph(Paragraph)
    /// An aside block.
    case aside(Aside)
    /// A block of sample code.
    case codeListing(CodeListing)
    /// A heading with the given level.
    case heading(Heading)
    /// A list that contains ordered items.
    case orderedList(OrderedList)
    
//    /// A list that contains unordered items.
//    case unorderedList(UnorderedList)
//
//    /// A step in a multi-step tutorial.
//    case step(TutorialStep)
//    /// A REST endpoint example that includes a request and the expected response.
//    case endpointExample(EndpointExample)
//    /// An example that contains a sample code block.
//    case dictionaryExample(DictionaryExample)
//
//    /// A list of terms.
//    case termList(TermList)
//    /// A table that contains a list of row data.
//    case table(Table)
//
//    /// A row in a grid-based layout system that describes a collection of columns.
//    case row(Row)
//
//    /// A paragraph of small print content that should be rendered in a small font.
//    case small(Small)
//
//    /// A collection of content that should be rendered in a tab-based layout.
//    case tabNavigator(TabNavigator)
//
//    /// A collection of authored links that should be rendered in a similar style
//    /// to links in an on-page Topics section.
//    case links(Links)
//
//    /// A video with an optional caption.
//    case video(Video)
//
//    /// An authored thematic break between block elements.
//    case thematicBreak
}

//extension BlockContent.Table: Equatable {
//    public static func == (lhs: BlockContent.Table, rhs: BlockContent.Table) -> Bool {
//        guard lhs.header == rhs.header
//                && lhs.extendedData == rhs.extendedData
//                && lhs.metadata == rhs.metadata
//                && lhs.rows == rhs.rows
//        else {
//            return false
//        }
//
//        var lhsAlignments = lhs.alignments
//        if let align = lhsAlignments, align.allSatisfy({ $0 == .unset }) {
//            lhsAlignments = nil
//        }
//
//        var rhsAlignments = rhs.alignments
//        if let align = rhsAlignments, align.allSatisfy({ $0 == .unset }) {
//            rhsAlignments = nil
//        }
//
//        return lhsAlignments == rhsAlignments
//    }
//}
//
//// Writing a manual Codable implementation for tables because the encoding of `extendedData` does
//// not follow from the struct layout.
//extension BlockContent.Table: Codable {
//    enum CodingKeys: String, CodingKey {
//        case header, alignments, rows, extendedData, metadata
//    }
//
//    // TableCellExtendedData encodes the row and column indices as a dynamic key with the format "{row}_{column}".
//    struct DynamicIndexCodingKey: CodingKey, Equatable {
//        let row, column: Int
//        init(row: Int, column: Int) {
//            self.row = row
//            self.column = column
//        }
//
//        var stringValue: String {
//            return "\(row)_\(column)"
//        }
//        init?(stringValue: String) {
//            let coordinates = stringValue.split(separator: "_")
//            guard coordinates.count == 2,
//                  let rowIndex = Int(coordinates.first!),
//                  let columnIndex = Int(coordinates.last!) else {
//                return nil
//            }
//            row = rowIndex
//            column = columnIndex
//        }
//        // The key is only represented by a string value
//        var intValue: Int? { nil }
//        init?(intValue: Int) { nil }
//    }
//
//    enum ExtendedDataCodingKeys: String, CodingKey {
//        case colspan, rowspan
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        self.header = try container.decode(BlockContent.HeaderType.self, forKey: .header)
//
//        let rawAlignments = try container.decodeIfPresent([BlockContent.ColumnAlignment].self, forKey: .alignments)
//        if let alignments = rawAlignments, !alignments.allSatisfy({ $0 == .unset }) {
//            self.alignments = alignments
//        } else {
//            self.alignments = nil
//        }
//
//        self.rows = try container.decode([BlockContent.TableRow].self, forKey: .rows)
//        self.metadata = try container.decodeIfPresent(ContentMetadata.self, forKey: .metadata)
//
//        var extendedData = Set<BlockContent.TableCellExtendedData>()
//        if container.contains(.extendedData) {
//            let dataContainer = try container.nestedContainer(keyedBy: DynamicIndexCodingKey.self, forKey: .extendedData)
//
//            for index in dataContainer.allKeys {
//                let cellContainer = try dataContainer.nestedContainer(keyedBy: ExtendedDataCodingKeys.self, forKey: index)
//                extendedData.insert(.init(rowIndex: index.row,
//                                          columnIndex: index.column,
//                                          colspan: try cellContainer.decode(UInt.self, forKey: .colspan),
//                                          rowspan: try cellContainer.decode(UInt.self, forKey: .rowspan)))
//            }
//        }
//        self.extendedData = extendedData
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(header, forKey: .header)
//        if let alignments, !alignments.isEmpty, !alignments.allSatisfy({ $0 == .unset }) {
//            try container.encode(alignments, forKey: .alignments)
//        }
//        try container.encode(rows, forKey: .rows)
//        try container.encodeIfPresent(metadata, forKey: .metadata)
//
//        if !extendedData.isEmpty {
//            var dataContainer = container.nestedContainer(keyedBy: DynamicIndexCodingKey.self, forKey: .extendedData)
//            for data in extendedData {
//                var cellContainer = dataContainer.nestedContainer(keyedBy: ExtendedDataCodingKeys.self,
//                                                                  forKey: .init(row: data.rowIndex, column: data.columnIndex))
//                try cellContainer.encode(data.colspan, forKey: .colspan)
//                try cellContainer.encode(data.rowspan, forKey: .rowspan)
//            }
//        }
//    }
//}
//
//// Codable conformance
//extension BlockContent: Codable {
//    private enum CodingKeys: CodingKey {
//        case type
//        case inlineContent, content, caption, style, name, syntax, code, level, text, items, media, runtimePreview, anchor, summary, example, metadata, start
//        case request, response
//        case header, rows
//        case numberOfColumns, columns
//        case tabs
//        case identifier
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let type = try container.decode(BlockType.self, forKey: .type)
//
//        switch type {
//        case .paragraph:
//            self = try .paragraph(.init(inlineContent: container.decode([RenderInlineContent].self, forKey: .inlineContent)))
//        case .aside:
//            var style = try container.decode(AsideStyle.self, forKey: .style)
//            if let displayName = try container.decodeIfPresent(String.self, forKey: .name) {
//                style = AsideStyle(displayName: displayName)
//            }
//            self = try .aside(.init(style: style, content: container.decode([BlockContent].self, forKey: .content)))
//        case .codeListing:
//            self = try .codeListing(.init(
//                syntax: container.decodeIfPresent(String.self, forKey: .syntax),
//                code: container.decode([String].self, forKey: .code),
//                metadata: container.decodeIfPresent(ContentMetadata.self, forKey: .metadata)
//            ))
//        case .heading:
//            self = try .heading(.init(level: container.decode(Int.self, forKey: .level), text: container.decode(String.self, forKey: .text), anchor: container.decodeIfPresent(String.self, forKey: .anchor)))
//        case .orderedList:
//            self = try .orderedList(.init(
//                items: container.decode([ListItem].self, forKey: .items),
//                startIndex: container.decodeIfPresent(UInt.self, forKey: .start) ?? 1
//            ))
//        case .unorderedList:
//            self = try .unorderedList(.init(items: container.decode([ListItem].self, forKey: .items)))
//        case .step:
//            self = try .step(.init(content: container.decode([BlockContent].self, forKey: .content), caption: container.decodeIfPresent([BlockContent].self, forKey: .caption) ?? [], media: container.decode(ReferenceIdentifier?.self, forKey: .media), code: container.decode(ReferenceIdentifier?.self, forKey: .code), runtimePreview: container.decode(ReferenceIdentifier?.self, forKey: .runtimePreview)))
//        case .endpointExample:
//            self = try .endpointExample(.init(
//                summary: container.decodeIfPresent([BlockContent].self, forKey: .summary),
//                request: container.decode(CodeExample.self, forKey: .request),
//                response: container.decode(CodeExample.self, forKey: .response)
//            ))
//        case .dictionaryExample:
//            self = try .dictionaryExample(.init(summary: container.decodeIfPresent([BlockContent].self, forKey: .summary), example: container.decode(CodeExample.self, forKey: .example)))
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
//                Small(inlineContent: container.decode([RenderInlineContent].self, forKey: .inlineContent))
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
//                    identifier: container.decode(ReferenceIdentifier.self, forKey: .identifier),
//                    metadata: container.decodeIfPresent(ContentMetadata.self, forKey: .metadata)
//                )
//            )
//        case .thematicBreak:
//            self = .thematicBreak
//        }
//    }
//
//    private enum BlockType: String, Codable {
//        case paragraph, aside, codeListing, heading, orderedList, unorderedList, step, endpointExample, dictionaryExample, table, termList, row, small, tabNavigator, links, video, thematicBreak
//    }
//
//    private var type: BlockType {
//        switch self {
//        case .paragraph: return .paragraph
//        case .aside: return .aside
//        case .codeListing: return .codeListing
//        case .heading: return .heading
//        case .orderedList: return .orderedList
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
//        default: fatalError("unknown BlockContent case in type property")
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(type, forKey: .type)
//
//        switch self {
//        case .paragraph(let p):
//            try container.encode(p.inlineContent, forKey: .inlineContent)
//        case .aside(let a):
//            try container.encode(a.style.renderKind, forKey: .style)
//            try container.encode(a.style.displayName, forKey: .name)
//            try container.encode(a.content, forKey: .content)
//        case .codeListing(let l):
//            try container.encode(l.syntax, forKey: .syntax)
//            try container.encode(l.code, forKey: .code)
//            try container.encodeIfPresent(l.metadata, forKey: .metadata)
//        case .heading(let h):
//            try container.encode(h.level, forKey: .level)
//            try container.encode(h.text, forKey: .text)
//            try container.encode(h.anchor, forKey: .anchor)
//        case .orderedList(let l):
//            if l.startIndex != 1 {
//                try container.encode(l.startIndex, forKey: .start)
//            }
//            try container.encode(l.items, forKey: .items)
//        case .unorderedList(let l):
//            try container.encode(l.items, forKey: .items)
//        case .step(let s):
//            try container.encode(s.content, forKey: .content)
//            try container.encode(s.caption, forKey: .caption)
//            try container.encode(s.media, forKey: .media)
//            try container.encode(s.code, forKey: .code)
//            try container.encode(s.runtimePreview, forKey: .runtimePreview)
//        case .endpointExample(let e):
//            try container.encodeIfPresent(e.summary, forKey: .summary)
//            try container.encode(e.request, forKey: .request)
//            try container.encode(e.response, forKey: .response)
//        case .dictionaryExample(let e):
//            try container.encodeIfPresent(e.summary, forKey: .summary)
//            try container.encode(e.example, forKey: .example)
//        case .table(let t):
//            // Defer to Table's own Codable implemenatation to format `extendedData` properly.
//            try t.encode(to: encoder)
//        case .termList(items: let l):
//            try container.encode(l.items, forKey: .items)
//        case .row(let row):
//            try container.encode(row.numberOfColumns, forKey: .numberOfColumns)
//            try container.encode(row.columns, forKey: .columns)
//        case .small(let small):
//            try container.encode(small.inlineContent, forKey: .inlineContent)
//        case .tabNavigator(let tabNavigator):
//            try container.encode(tabNavigator.tabs, forKey: .tabs)
//        case .links(let links):
//            try container.encode(links.style, forKey: .style)
//            try container.encode(links.items, forKey: .items)
//        case .video(let video):
//            try container.encode(video.identifier, forKey: .identifier)
//            try container.encodeIfPresent(video.metadata, forKey: .metadata)
//        case .thematicBreak:
//            break
//        default:
//            fatalError("unknown BlockContent case in encode method")
//        }
//    }
//}
