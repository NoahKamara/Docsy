//
//  SampleDownloadSection.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// A section that contains download data for a sample project.
///
/// The `action` property is the reference to the file for download, e.g., `sample.zip`.
public struct SampleDownloadSection: SectionProtocol, Equatable {
    public var kind: Kind = .sampleDownload
    /// The call to action in the section.
    public var action: InlineContent

    /// Creates a new sample project download section.
    /// - Parameter action: The call to action in the section.
    public init(action: InlineContent) {
        self.action = action
    }

    // MARK: - Codable

    /// The list of keys you use to encode or decode this section.
    public enum CodingKeys: String, CodingKey {
        case kind, action
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.action = try container.decode(InlineContent.self, forKey: .action)
    }
}
