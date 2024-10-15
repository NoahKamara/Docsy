//
//  DataProvider.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public protocol DataProvider: Sendable {
    /// A string that uniquely identifies this data provider.
    ///
    /// Unless your implementation needs a stable identifier to associate with an external system, it's reasonable to
    /// use `UUID().uuidString` for the provider's identifier.
    var identifier: String { get }

    /// Returns the data backing one of the files that this data provider provides.
    ///
    /// A data provider will only receive URLs that it provides.
    ///
    /// - Parameter url: The URL of a file to return the backing data for.
    func contentsOfURL(_ url: URL) async throws -> Data

    /// Returns the documentation bundles that your data provider provides.
    func bundles() async throws -> [DocumentationBundle]
}
