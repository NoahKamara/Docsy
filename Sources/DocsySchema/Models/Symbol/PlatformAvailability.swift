//
//  PlatformAvailability.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// Availability information of a symbol on a specific platform.
public struct PlatformAvailability: Codable, Hashable, Equatable {
    /// The name of the platform on which the symbol is available.
    public let name: String?

    /// version introducing the symbol.
    public let introduced: String?

    /// version  deprecating the symbol.
    public let deprecated: String?

    /// version  marking the symbol as obsolete.
    public let obsoleted: String?

    /// message associated with the availability of the symbol.
    public let message: String?

    /// new name of the symbol, if it was renamed.
    public let renamed: String?

    /// if the symbol is deprecated
    public let unconditionallyDeprecated: Bool?

    /// If the symbol is unavailable
    public let unconditionallyUnavailable: Bool?

    /// If the symbol is introduced in a beta version
    public let isBeta: Bool?
}
