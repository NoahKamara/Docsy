//
//  File 2.swift
//  Docsy
//
//  Created by Noah Kamara on 25.08.24.
//

import Testing
import Foundation
@testable import Docsy


@Suite("Provider Registration")
struct ProviderRegistrationTest {
    let rootURL = URL(filePath: "/Users/noahkamara/Developer/DocSee/docc.doccarchive")

    @Test("before Context.init")
    func registerBeforeContextInit() async throws {
        let workspace = DocumentationWorkspace()

        let provider = try LocalFileSystemDataProvider(rootURL: rootURL)
        try await workspace.registerProvider(provider)

        let context = try await DocumentationContext(dataProvider: workspace)

        let bundle = try #require(context.bundles["org.swift.docc"])

        #expect(bundle.identifier == "org.swift.docc")
        #expect(bundle.displayName == "docc")
    }

    @Test("after Context.init")
    func registerAfterContextInit() async throws {
        let workspace = DocumentationWorkspace()
        let context = try await DocumentationContext(dataProvider: workspace)

        let provider = try LocalFileSystemDataProvider(rootURL: rootURL)
        try await workspace.registerProvider(provider)

        let bundle = try #require(context.bundles["org.swift.docc"])

        #expect(bundle.identifier == "org.swift.docc")
        #expect(bundle.displayName == "docc")
    }

    @Test("unregister")
    func unregister() async throws {
        let workspace = DocumentationWorkspace()

        let provider = try LocalFileSystemDataProvider(rootURL: rootURL)
        try await workspace.registerProvider(provider)
        let context = try await DocumentationContext(dataProvider: workspace)

        let bundle = try #require(context.bundles["org.swift.docc"])

        #expect(bundle.identifier == "org.swift.docc")
        #expect(bundle.displayName == "docc")

        try await workspace.unregisterProvider(provider)

        #expect(context.bundles.isEmpty)
    }
}
