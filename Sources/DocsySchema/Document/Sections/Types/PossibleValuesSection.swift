//
//  PossibleValuesSection.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// A section that lists a pre-defined list of possible values for a given symbol.
///
/// For example, a property list key setting a target platform has allowed values of: "ppc", "i386", and "arm".
public struct PossibleValuesSection: SectionProtocol, Equatable {
    /// A named value and optional details content.
    ///
    /// Some values are self-explanatory in their context like "2" or "Info.plist". For values
    /// that are not, provide additional details like so:
    /// - name: "Default"
    /// - content: Use "Default" to load the first-available instance.
    public struct NamedValue: Decodable, Equatable {
        /// The value name.
        let name: String
        /// Details content, if any.
        let content: [BlockContent]?
    }

    public var kind: Kind = .possibleValues
    /// The title for the section, `nil` by default.
    public let title: String?
    /// The list of named values.
    public let values: [NamedValue]

    /// Creates a new possible values section.
    /// - Parameter title: The section title.
    /// - Parameter values: The list of values for this section.
    public init(title: String, values: [NamedValue]) {
        self.title = title
        self.values = values
    }

    // MARK: - Codable

    /// The list of keys you use to encode or decode this section.
    public enum CodingKeys: String, CodingKey {
        case kind, title, values
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.values = try container.decode([NamedValue].self, forKey: .values)
    }
}
