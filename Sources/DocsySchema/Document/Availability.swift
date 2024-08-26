//
//  File.swift
//  Docsy
//
//  Created by Noah Kamara on 26.08.24.
//

import Foundation

/// Availability information of a symbol on a specific platform.
public struct Availability: Codable, Hashable, Equatable {
    /// The name of the platform on which the symbol is available.
    public let name: String?

    /// The version of the platform SDK introducing the symbol.
    public let introduced: String?

    /// The version of the platform SDK deprecating the symbol.
    public let deprecated: String?

    /// The version of the platform SDK marking the symbol as obsolete.
    public let obsoleted: String?

    /// A message associated with the availability of the symbol.
    ///
    /// Use this property to provide a deprecation reason or instructions how to
    /// update code that uses this symbol.
    public let message: String?

    /// The new name of the symbol, if it was renamed.
    public let renamed: String?

    /// If `true`, the symbol is deprecated on this or all platforms.
    public let unconditionallyDeprecated: Bool?

    /// If `true`, the symbol is unavailable on this or all platforms.
    public let unconditionallyUnavailable: Bool?

    /// If `true`, the symbol is introduced in a beta version of this platform.
    public let isBeta: Bool?

    private enum CodingKeys: String, CodingKey {
        case name, introducedAt, deprecatedAt, obsoletedAt, message, renamed, deprecated, unavailable
        case beta
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        introduced = try container.decodeIfPresent(String.self, forKey: .introducedAt)
        deprecated = try container.decodeIfPresent(String.self, forKey: .deprecatedAt)
        obsoleted = try container.decodeIfPresent(String.self, forKey: .obsoletedAt)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        renamed = try container.decodeIfPresent(String.self, forKey: .renamed)
        unconditionallyDeprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated)
        unconditionallyUnavailable = try container.decodeIfPresent(Bool.self, forKey: .unavailable)
        isBeta = try container.decodeIfPresent(Bool.self, forKey: .beta)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(introduced, forKey: .introducedAt)
        try container.encodeIfPresent(deprecated, forKey: .deprecatedAt)
        try container.encodeIfPresent(obsoleted, forKey: .obsoletedAt)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(renamed, forKey: .renamed)
        try container.encodeIfPresent(unconditionallyDeprecated, forKey: .deprecated)
        try container.encodeIfPresent(unconditionallyUnavailable, forKey: .unavailable)
        try container.encodeIfPresent(isBeta, forKey: .beta)
    }
}
