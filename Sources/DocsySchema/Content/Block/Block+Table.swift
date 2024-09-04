
public extension BlockContent {
    // MARK: Table

    /// A table that contains a list of row data.
    struct Table: Schema {
        /// The style of header in this table.
        public var header: HeaderType
        /// The text alignment of each column in this table.
        ///
        /// A `nil` value for this property is the same as all the columns being
        /// ``BlockContent/ColumnAlignment/unset``.
        public var alignments: [ColumnAlignment]?

        /// The rows in this table.
        public var rows: [TableRow]

        /// Any extended information that describes cells in this table.
        public var extendedData: Set<TableCellExtendedData>

        /// Additional metadata for this table, if present.
        public var metadata: ContentMetadata?

        /// Creates a new table with the given data.
        ///
        /// - Parameters:
        ///   - header: The style of header in this table.
        ///   - rawAlignments: The text alignment for each column in this table. If all the
        ///     alignments are ``BlockContent/ColumnAlignment/unset``, the ``alignments``
        ///     property will be set to `nil`.
        ///   - rows: The cell data for this table.
        ///   - extendedData: Any extended information that describes cells in this table.
        ///   - metadata: Additional metadata for this table, if necessary.
        public init(header: HeaderType, rawAlignments: [ColumnAlignment]? = nil, rows: [TableRow], extendedData: Set<TableCellExtendedData>, metadata: ContentMetadata? = nil) {
            self.header = header
            self.rows = rows
            self.extendedData = extendedData
            self.metadata = metadata
            if let alignments = rawAlignments, !alignments.allSatisfy({ $0 == .unset }) {
                self.alignments = alignments
            }
        }
    }
}

public extension BlockContent.Table {
    static func == (lhs: BlockContent.Table, rhs: BlockContent.Table) -> Bool {
        guard lhs.header == rhs.header
            && lhs.extendedData == rhs.extendedData
            && lhs.metadata == rhs.metadata
            && lhs.rows == rhs.rows
        else {
            return false
        }

        var lhsAlignments = lhs.alignments
        if let align = lhsAlignments, align.allSatisfy({ $0 == .unset }) {
            lhsAlignments = nil
        }

        var rhsAlignments = rhs.alignments
        if let align = rhsAlignments, align.allSatisfy({ $0 == .unset }) {
            rhsAlignments = nil
        }

        return lhsAlignments == rhsAlignments
    }
}

// Writing a manual Codable implementation for tables because the encoding of `extendedData` does
// not follow from the struct layout.
extension BlockContent.Table {
    enum CodingKeys: String, CodingKey {
        case header, alignments, rows, extendedData, metadata
    }

    // TableCellExtendedData encodes the row and column indices as a dynamic key with the format "{row}_{column}".
    struct DynamicIndexCodingKey: CodingKey, Equatable {
        let row, column: Int
        init(row: Int, column: Int) {
            self.row = row
            self.column = column
        }

        var stringValue: String {
            return "\(row)_\(column)"
        }

        init?(stringValue: String) {
            let coordinates = stringValue.split(separator: "_")
            guard coordinates.count == 2,
                  let rowIndex = Int(coordinates.first!),
                  let columnIndex = Int(coordinates.last!)
            else {
                return nil
            }
            row = rowIndex
            column = columnIndex
        }

        // The key is only represented by a string value
        var intValue: Int? { nil }
        init?(intValue _: Int) { nil }
    }

    enum ExtendedDataCodingKeys: String, CodingKey {
        case colspan, rowspan
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        header = try container.decode(BlockContent.HeaderType.self, forKey: .header)

        let rawAlignments = try container.decodeIfPresent([BlockContent.ColumnAlignment].self, forKey: .alignments)
        if let alignments = rawAlignments, !alignments.allSatisfy({ $0 == .unset }) {
            self.alignments = alignments
        } else {
            alignments = nil
        }

        rows = try container.decode([BlockContent.TableRow].self, forKey: .rows)
        metadata = try container.decodeIfPresent(ContentMetadata.self, forKey: .metadata)

        var extendedData = Set<BlockContent.TableCellExtendedData>()
        if container.contains(.extendedData) {
            let dataContainer = try container.nestedContainer(keyedBy: DynamicIndexCodingKey.self, forKey: .extendedData)

            for index in dataContainer.allKeys {
                let cellContainer = try dataContainer.nestedContainer(keyedBy: ExtendedDataCodingKeys.self, forKey: index)
                try extendedData.insert(.init(rowIndex: index.row,
                                              columnIndex: index.column,
                                              colspan: cellContainer.decode(UInt.self, forKey: .colspan),
                                              rowspan: cellContainer.decode(UInt.self, forKey: .rowspan)))
            }
        }
        self.extendedData = extendedData
    }
}

public extension BlockContent {
    // MARK: Row

    /// A table row that contains a list of row cells.
    struct TableRow: Schema {
        /// A list of rendering block elements.
        public typealias Cell = [BlockContent]
        /// The list of row cells.
        public let cells: [Cell]

        /// Creates a new table row.
        /// - Parameter cells: The list of row cells to use.
        public init(cells: [Cell]) {
            self.cells = cells
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            cells = try container.decode([Cell].self)
        }
    }

    // MARK: Extended Data

    /// Extended data that may be applied to a table cell.
    struct TableCellExtendedData: Schema, Hashable {
        /// The row coordinate for the cell described by this data.
        public let rowIndex: Int
        /// The column coordinate for the cell described by this data.
        public let columnIndex: Int

        /// The number of columns this cell spans over.
        ///
        /// A value of 1 is the default. A value of zero means that this cell is being "spanned
        /// over" by a previous cell in this row. A value of greater than 1 means that this cell
        /// "spans over" later cells in this row.
        public let colspan: UInt

        /// The number of rows this cell spans over.
        ///
        /// A value of 1 is the default. A value of zero means that this cell is being "spanned
        /// over" by another cell in a previous row. A value of greater than one means that this
        /// cell "spans over" other cells in later rows.
        public let rowspan: UInt

        public init(rowIndex: Int, columnIndex: Int,
                    colspan: UInt, rowspan: UInt)
        {
            self.rowIndex = rowIndex
            self.columnIndex = columnIndex
            self.colspan = colspan
            self.rowspan = rowspan
        }
    }
}

public extension BlockContent {
    // MARK: Header

    /// The table headers style.
    enum HeaderType: String, Schema {
        /// The first row in the table contains column headers.
        case row
        /// The first column in the table contains row headers.
        case column
        /// Both the first row and column contain headers.
        case both
        /// The table doesn't contain headers.
        case none
    }

    // MARK: Column Alignment

    /// The methods by which a table column can have its text aligned.
    enum ColumnAlignment: String, Schema {
        /// Force text alignment to be left-justified.
        case left
        /// Force text alignment to be right-justified.
        case right
        /// Force text alignment to be centered.
        case center
        /// Leave text alignment to the default.
        case unset
    }
}
