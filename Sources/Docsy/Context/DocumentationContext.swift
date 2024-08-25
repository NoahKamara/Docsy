
import Foundation
import Synchronization

struct CacheKey<T> {
    let identifier: String

    init(_ identifier: String, of type: T.Type = T.self) {
        self.identifier = identifier
    }
}

class Cache {
    private var cache: [String: Any] = [:]

    subscript<T>(_ key: CacheKey<T>) -> T? {
        cache[key.identifier] as? T
    }
    
    func put(_ data: Data, for key: String) {
        cache[key] = data
    }
}

@Observable
public class DocumentationContext {
    private let decoder = JSONDecoder()
    private let dataProvider: DocumentationContextDataProvider

    public var bundleIdentifiers: [BundleIdentifier] {
        access(keyPath: \.bundles)
        return bundles.keys.sorted()
    }

    private(set) public var bundles: [BundleIdentifier: DocumentationBundle] = [:]

//    public let index = Index()

    /// Initializes a documentation context with a given `dataProvider` and registers all the documentation bundles that it provides.
    ///
    /// - Parameter dataProvider: The data provider to register bundles from.
    @MainActor public init(dataProvider: DocumentationContextDataProvider) {
        self.dataProvider = dataProvider
        dataProvider.delegate = self
    }

    public enum ContextError: Error {
        case unknownBundle(BundleIdentifier)
    }

    public func contents(for reference: TopicReference) async throws -> Data {
        let bundle = try bundle(for: reference.bundleIdentifier)
        return try await dataProvider.contentsOfURL(reference.url, in: bundle)
    }

    public func bundle(for identifier: BundleIdentifier) throws(ContextError) -> DocumentationBundle {
        guard let bundle = bundles[identifier] else {
            throw .unknownBundle(identifier)
        }
        return bundle
    }

    public func index(for identifier: BundleIdentifier) async throws -> DocumentationIndex {
        let provider = self.dataProvider
        let decoder = decoder
        let bundle = try bundle(for: identifier)

        return try await Task.detached {
            let indexData = try await provider.contentsOfURL(bundle.indexURL, in: bundle)
            return try decoder.decode(DocumentationIndex.self, from: indexData)
        }.value
    }

    @Observable
    public class Index {
        private(set) var bundles: [BundleIdentifier: DocumentationIndex] = [:]

        public var isEmpty: Bool { bundles.isEmpty }

        public var keys: [BundleIdentifier: DocumentationIndex].Keys { bundles.keys }
        public subscript(_ key: BundleIdentifier) -> DocumentationIndex? {
            access(keyPath: \.bundles[key])
            return bundles[key]
        }

        @MainActor
        func register(_ index: DocumentationIndex, for identifier: BundleIdentifier) {
            withMutation(keyPath: \.bundles) {
                bundles[identifier] = index
            }
        }

        @MainActor
        func remove(_ identifier: BundleIdentifier) {
            withMutation(keyPath: \.bundles) {
                _ = bundles.removeValue(forKey: identifier)
            }
        }
    }
}

struct ResolvedBundleReference: Codable, Hashable {
    let bundleIdentifier: BundleIdentifier
    let path: String
}


extension DocumentationContext: DocumentationContextDataProviderDelegate {
    public func dataProvider(_ dataProvider: any DocumentationContextDataProvider, didAddBundle bundle: DocumentationBundle) {
        print("DID ADD")
        register(bundle)
    }

    public func dataProvider(_ dataProvider: any DocumentationContextDataProvider, didRemoveBundle bundle: DocumentationBundle) {
        print("DID REMOVE")
        withMutation(keyPath: \.bundles) {
            _ = self.bundles.removeValue(forKey: bundle.identifier)
        }
    }
    
    @MainActor fileprivate func register(_ bundle: DocumentationBundle) {
        withMutation(keyPath: \.bundles) {
            self.bundles[bundle.identifier] = bundle
        }
//        let indexData = try await dataProvider.contentsOfURL(bundle.indexURL, in: bundle)
//        let bundleIndex = try decoder.decode(DocumentationIndex.self, from: indexData)
//
//
//        await self.index.register(bundleIndex, for: bundle.identifier)
    }
}

