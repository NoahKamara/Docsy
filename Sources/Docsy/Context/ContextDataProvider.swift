
import Foundation

/// A type that provides information about documentation bundles and their content.
public protocol DocumentationContextDataProvider: Actor {
    /// An object to notify when bundles are added or removed.
    @MainActor var delegate: DocumentationContextDataProviderDelegate? { get set }

    /// The documentation bundles that this data provider provides.
    var bundles: [BundleIdentifier: DocumentationBundle] { get }

    /// Returns the data for the specified `url` in the provided `bundle`.
    ///
    /// - Parameters:
    ///   - url: The URL of the file to read.
    ///   - bundle: The bundle that the file is a part of.
    ///
    /// - Throws: When the file cannot be found in the workspace.
    func contentsOfURL(_ url: URL, in bundle: DocumentationBundle) async throws -> Data
}

/// An object that responds to changes in available documentation bundles for a specific provider.
@MainActor
public protocol DocumentationContextDataProviderDelegate: AnyObject {
    /// Called when the `dataProvider` has added a new documentation bundle to its list of `bundles`.
    ///
    /// - Parameters:
    ///   - dataProvider: The provider that added this bundle.
    ///   - bundle: The bundle that was added.
    ///
    /// - Note: This method is called after the `dataProvider` has been added the bundle to its `bundles` property.
    @MainActor func dataProvider(_ dataProvider: DocumentationContextDataProvider, didAddBundle bundle: DocumentationBundle)

    /// Called when the `dataProvider` has removed a documentation bundle from its list of `bundles`.
    ///
    /// - Parameters:
    ///   - dataProvider: The provider that removed this bundle.
    ///   - bundle: The bundle that was removed.
    ///
    /// - Note: This method is called after the `dataProvider` has been removed the bundle from its `bundles` property.
    @MainActor func dataProvider(_ dataProvider: DocumentationContextDataProvider, didRemoveBundle bundle: DocumentationBundle)
}
