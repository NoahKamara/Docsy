//
//  NavigatorIndex.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import OSLog

public class NavigatorIndex {
    static let logger = Logger.docsy("Index")

    public init() {
        self.tree = NavigatorTree()
    }

    /// The tree of the index
    public let tree: NavigatorTree
}

public extension NavigatorIndex {
    /// Loads the bundle's index into this instance, adding it to the tree
    /// - Parameters:
    ///   - bundle: A Bundle that was provided by the dataProvider
    ///   - dataProvider: A provider of documentation data
    func load(
        for bundle: DocumentationBundle,
        with dataProvider: any DocumentationContextDataProvider
    ) async throws {
        Self.logger.info("[\(bundle.identifier)] loading")

        let index: DocumentationIndex = try await {
            do {
                let data = try await dataProvider.contentsOfURL(bundle.indexURL, in: bundle)
                let index = try JSONDecoder().decode(DocumentationIndex.self, from: data)
                return index
            } catch let error as any DescribedError {
                Self.logger.error("[\(bundle.identifier)] failed: \(error.errorDescription)")
                throw error
            } catch {
                Self.logger.error("[\(bundle.identifier)] failed: \(error)")
                throw error
            }
        }()

        let bundleRoot = bundle.rootReference
        Self.logger.debug("[\(bundle.identifier)] found Index \(index.schemaVersion)")

        let langGroups = index.interfaceLanguages.values.map { lang, nodes in
            let children = nodes.map {
                Node(resolving: $0, at: bundleRoot)
            }
            Self.logger.debug("[\(bundle.identifier)] found language: \(lang.id) with \(nodes[0].title) elements")

            return LanguageGroup(lang, children: children)
        }

        let bundleNode = BundleNode(bundle: bundle, children: langGroups)
        await tree.insertBundle(bundleNode)
    }

    /// Unloads the bundle's index from this instance by removing it from the tree
    /// - Parameters:
    ///   - bundle: A Bundle that was provided by the dataProvider
    ///   - dataProvider: A provider of documentation data
    @MainActor
    func unload(bundle: DocumentationBundle) {
        Self.logger.info("[\(bundle.identifier)] unlodaing")
        tree.removeBundle(bundle.identifier)
    }
}
