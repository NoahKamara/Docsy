//
//  PlistDetailsSection.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// A style for how to render links to a property list key or an entitlement key.
public enum PropertyListTitleStyle: String, Codable, Equatable, Sendable {
    /// Render links to the property list key using the raw key, for example "com.apple.enableDataAccess".
    ///
    /// ## See Also
    /// - ``TopicRenderReference/PropertyListKeyNames/rawKey``
    case useRawKey = "symbol"
    /// Render links to the property list key using the display name, for example "Enables Data Access".
    ///
    /// ## See Also
    /// - ``TopicRenderReference/PropertyListKeyNames/displayName``
    case useDisplayName = "title"
}

/// A section that contains details about a property list key.
public struct PlistDetailsSection: SectionProtocol, Equatable {
    public var kind: Kind = .plistDetails
    /// A title for the section.
    public var title = "Details"

    /// Details for a property list key.
    public struct Details: Decodable, Equatable {
        /// The name of the key.
        public let rawKey: String
        /// A list of types acceptable for this key's value.
        public let value: [TypeDetails]
        /// A list of platforms to which this key applies.
        public let platforms: [String]
        /// An optional, human-friendly name of the key.
        public let displayName: String?
        /// A title rendering style.
        public let titleStyle: PropertyListTitleStyle

        enum CodingKeys: String, CodingKey {
            case rawKey = "name"
            case value
            case platforms
            case displayName = "ideTitle"
            case titleStyle
        }
    }

    /// The details of the property key.
    public let details: Details
}
