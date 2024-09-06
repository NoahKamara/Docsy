/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021-2023 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import Foundation

/// A reference to a file resource.
///
/// File resources are used, for example, to display the contents of a source code file in a Tutorial's step.
public struct FileReference: ReferenceProtocol, Equatable {
    /// The type of this file reference.
    ///
    /// This value is always `.file`.
    public let type: ReferenceType = .file

    /// The identifier of this reference.
    public let identifier: ReferenceIdentifier

    /// The name of the file.
    public let fileName: String

    /// The type of the file, typically represented by its file extension.
    public let fileType: String

    /// The syntax for the content in the file, for example "swift".
    ///
    /// You can use this value to identify the syntax of the content. This would allow, for example, a renderer to perform syntax highlighting of the file's content.
    public let syntax: String

    /// The line-by-line contents of the file.
    public let content: [String]

    /// The line highlights for this file.
    public private(set) var highlights: [LineHighlight] = []

    enum CodingKeys: CodingKey {
        case type
        case identifier
        case fileName
        case fileType
        case syntax
        case content
        case highlights
    }

    init(identifier: ReferenceIdentifier, fileName: String, fileType: String, syntax: String, content: [String], highlights: [LineHighlight]) {
        self.identifier = identifier
        self.fileName = fileName
        self.fileType = fileType
        self.syntax = syntax
        self.content = content
        self.highlights = highlights
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try values.decode(ReferenceIdentifier.self, forKey: .identifier)
        self.fileName = try values.decode(String.self, forKey: .fileName)
        self.fileType = try values.decode(String.self, forKey: .fileType)
        self.syntax = try values.decode(String.self, forKey: .syntax)
        self.content = try values.decode([String].self, forKey: .content)
        self.highlights = try values.decodeIfPresent([LineHighlight].self, forKey: .highlights) ?? []
    }
}

public struct LineHighlight: Codable, Equatable, Sendable {
    /// The line to highlight.
    public let line: Int

    /// If non-`nil`, the column to start the highlight.
    public let start: Int?

    /// If non-`nil`, the length of the highlight in columns.
    public let length: Int?

    /// Creates a new highlight for a single line.
    ///
    /// - Parameters:
    ///   - line: The line to highlight.
    ///   - start: The column in which to start the highlight.
    ///   - length: The character length of the highlight.
    public init(line: Int, start: Int? = nil, length: Int? = nil) {
        self.line = line
        self.start = start
        self.length = length
    }
}

/// A reference to a type of file.
///
/// This is not a reference to a specific file, but rather to a type of file. Use a file type reference together with a file reference to display an icon for that file type
/// alongside the content of that file. For example, a property list file icon alongside the content of a specific property list file.
public struct FileTypeReference: ReferenceProtocol, Equatable {
    public var type: ReferenceType = .fileType

    /// The identifier of this reference.
    public var identifier: ReferenceIdentifier

    /// The display name of the file type.
    public var displayName: String

    /// The icon for this file type, encoded in Base64.
    public var iconBase64: Data

    /// Creates a new file type reference.
    /// - Parameters:
    ///   - identifier: The identifier of this reference.
    ///   - displayName: The display name of the file type.
    ///   - iconBase64: The icon for this file type, encoded in Base64.
    public init(identifier: ReferenceIdentifier, displayName: String, iconBase64: Data) {
        self.identifier = identifier
        self.displayName = displayName
        self.iconBase64 = iconBase64
    }
}
