//
//  File 2.swift
//  Docsy
//
//  Created by Noah Kamara on 25.08.24.
//

@testable import Docsy
import Foundation
import Testing

@Suite("Provider Registration")
@MainActor
struct ProviderRegistrationTest {
    let rootURL = Resources.docc

//    struct ProviderTestCase<T> {
//        let url: T
//        let provider: any DataProvider
//
//        init(url: T, provider: some DataProvider) {
//            self.url = url
//            self.provider = provider
//        }
//
//        static func make<P: DataProvider>(urls: some Sequence<T>, makeProvider: (T) throws -> P) rethrows -> [ProviderTestCase] {
//            do {
//                return try urls.map({ .init(url: $0, provider: try makeProvider($0)) })
//            } catch {
//                print(error)
//                fatalError("Failed to create test cases: \(error)")
//            }
//        }
//    }
//
//
    @Test("before Context.init")
    func registerBeforeContextInit() async throws {
        let workspace = DocumentationWorkspace()

        let provider = try LocalFileSystemDataProvider(rootURL: rootURL)
        try await workspace.registerProvider(provider)

        let context = DocumentationContext(dataProvider: workspace)

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
        let context = DocumentationContext(dataProvider: workspace)

        let bundle = try #require(context.bundles["org.swift.docc"])

        #expect(bundle.identifier == "org.swift.docc")
        #expect(bundle.displayName == "docc")

        try await workspace.unregisterProvider(provider)

        #expect(context.bundles.isEmpty)
    }
}
