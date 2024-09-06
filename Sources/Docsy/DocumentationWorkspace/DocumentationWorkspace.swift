import Foundation
import OSLog


public actor DocumentationWorkspace: DocumentationContextDataProvider {
    static let logger = Logger.docsy("Workspace")

    /// An error when requesting information from a workspace.
    public enum WorkspaceError: Error {
        /// A bundle with the provided ID wasn't found in the workspace.
        case unknownBundle(id: String)
        /// A data provider with the provided ID wasn't found in the workspace.
        case unknownProvider(id: String)

        /// A plain-text description of the error.
        public var errorDescription: String {
            switch self {
            case .unknownBundle(let id):
                "The requested data could not be located because a containing bundle with id '\(id)' could not be found in the workspace."
            case .unknownProvider(let id):
                "The requested data could not be located because a containing data provider with id '\(id)' could not be found in the workspace."
            }
        }
    }

    /// Reads the data for a given file in a given documentation bundle.
    ///
    /// - Parameters:
    ///   - url: The URL of the file to read.
    ///   - bundle: The documentation bundle that the file belongs to.
    /// - Throws: A ``WorkspaceError/unknownBundle(id:)`` error if the bundle doesn't exist in the workspace or
    ///           a ``WorkspaceError/unknownProvider(id:)`` error if the bundle's data provider doesn't exist in the workspace.
    /// - Returns: The raw data for the given file.
    public func contentsOfURL(_ url: URL, in bundle: DocumentationBundle) async throws -> Data {
        guard let providerID = bundleToProvider[bundle.identifier] else {
            throw WorkspaceError.unknownBundle(id: bundle.identifier)
        }

        guard let provider = providers[providerID] else {
            throw WorkspaceError.unknownProvider(id: providerID)
        }

        return try await Task.detached {
            try await provider.contentsOfURL(url)
        }.value
    }

    /// A map of bundle identifiers to documentation bundles.
    public var bundles: [String: DocumentationBundle] = [:]

    /// A map of provider identifiers to data providers.
    private var providers: [String: DataProvider] = [:]

    /// A map of bundle identifiers to provider identifiers (in other words, a map from a bundle to the provider that vends the bundle).
    private var bundleToProvider: [String: String] = [:]

    /// The delegate to notify when documentation bundles are added or removed from this workspace.
    @MainActor public weak var delegate: DocumentationContextDataProviderDelegate?

    /// Creates a new, empty documentation workspace.
    public init() {}

    /// Adds a new data provider to the workspace.
    ///
    /// Adding a data provider also adds the documentation bundles that it provides, and notifies the ``delegate`` of the added bundles.
    ///
    /// - Parameters:
    ///   - provider: The workspace data provider to add to the workspace.
    ///   - options: The options that the data provider uses to discover documentation bundles that it provides to the delegate.
    public func registerProvider(_ provider: DataProvider) async throws {
        Self.logger.debug("[\(provider.identifier)] register '\(type(of: provider))'")

        // We must add the provider before adding the bundle so that the delegate
        // may start making requests immediately.
        providers[provider.identifier] = provider

        let discoveredBundles = try await provider.bundles()

        for bundle in discoveredBundles {
            Self.logger.info("[\(provider.identifier)] register bundle: '\(bundle.identifier)'")
            bundles[bundle.identifier] = bundle
            bundleToProvider[bundle.identifier] = provider.identifier
            Task { @MainActor in
                delegate?.dataProvider(self, didAddBundle: bundle)
            }
        }
    }

    /// Removes a given data provider from the workspace.
    ///
    /// Removing a data provider also removes all its provided documentation bundles and notifies the ``delegate`` of the removed bundles.
    ///
    /// - Parameters:
    ///   - provider: The workspace data provider to remove from the workspace.
    ///   - options: The options that the data provider uses to discover documentation bundles that it removes from the delegate.
    public func unregisterProvider(_ provider: DataProvider) async throws {
        Self.logger.info("[\(provider.identifier)] unregister provider")

        for (bundleIdentifier, providerIdentifier) in bundleToProvider {
            guard providerIdentifier == provider.identifier else {
                continue
            }
            Self.logger.info("[\(provider.identifier)] unregister bundle: '\(bundleIdentifier)'")
            guard let bundle = bundles.removeValue(forKey: bundleIdentifier) else {
                return
            }
            bundleToProvider[providerIdentifier] = nil

            await Task { @MainActor in
                delegate?.dataProvider(self, didRemoveBundle: bundle)
            }.value
        }

        // The provider must be removed after removing the bundle so that the delegate
        // may continue making requests as part of removing the bundle.
        providers[provider.identifier] = nil
    }
}
