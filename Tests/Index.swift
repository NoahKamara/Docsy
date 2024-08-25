//
//  File 2.swift
//  Docsy
//
//  Created by Noah Kamara on 25.08.24.
//

import Testing
import Foundation
@testable import Docsy

@Suite("Index")
struct IndexTexts {
    let rootURL = URL(filePath: "/Users/noahkamara/Developer/DocSee/docc.doccarchive")

    @Test
    func content() async throws {
        let workspace = DocumentationWorkspace()
        let provider = try LocalFileSystemDataProvider(rootURL: rootURL)
        try await workspace.registerProvider(provider)
        let context = try await DocumentationContext(dataProvider: workspace)

        let index = try #require(context.index.bundles["org.swift.docc"])

        let module = try #require(index.interfaceLanguages.swift?.first)

        #expect(module.title == "DocC")
        #expect(module.type == .framework)

        let children = try #require(module.children)
        #expect(children.count >= 2)

        let essentials = children[0]

        #expect(essentials.title == "Essentials")
        #expect(essentials.type == .groupMarker)

        let article = children[1]
        #expect(article.path == "/documentation/docc/documenting-a-swift-framework-or-package")
        #expect(article.title == "Documenting a Swift Framework or Package")
        #expect(article.type == .article)
    }
}
