
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


    public enum ReferenceResolverError: DescribedError {
        case unknownBundle(BundleIdentifier)

        public var errorDescription: String {
            let msg = switch self {
            case .unknownBundle(let bundleIdentifier): "Unknown Bundle '\(bundleIdentifier)'"
            }

            return "failed to resolve reference :" + msg
        }
    }

    /// Fetches the parents of the documentation node with the given `reference`.
    ///
    /// - Parameter reference: The reference of the node to fetch parents for.
    /// - Returns: A list of the reference for the given node's parent nodes.
//    public func parents(of reference: TopicReference) -> [TopicReference] {
//        return topicGraph.reverseEdges[reference] ?? []
//    }

//    /// Returns the document URL for the given article or tutorial reference.
//    ///
//    /// - Parameter reference: The identifier for the topic whose file URL to locate.
//    /// - Returns: If the reference is a reference to a known Markdown document, this function returns the article's URL, otherwise `nil`.
//    public func documentURL(for reference: TopicReference) -> URL? {
//        if let node = topicGraph.nodes[reference], case .file(let url) = node.source {
//            return url
//        }
//        return nil
//    }
//
//    /// Returns the URL of the documentation extension of the given reference.
//    ///
//    /// - Parameter reference: The reference to the symbol this function should return the documentation extension URL for.
//    /// - Returns: The document URL of the given symbol reference. If the given reference is not a symbol reference, returns `nil`.
//    public func documentationExtensionURL(for reference: ResolvedTopicReference) -> URL? {
//        guard (try? entity(with: reference))?.kind.isSymbol == true else {
//            return nil
//        }
//        return documentLocationMap[reference]
//    }
//
//    /// Attempt to locate the reference for a given file.
//    ///
//    /// - Parameter url: The file whose reference to locate.
//    /// - Returns: The reference for the file if it could be found, otherwise `nil`.
//    public func referenceForFileURL(_ url: URL) -> ResolvedTopicReference? {
//        return documentLocationMap[url]
//    }
//
//
    public func document(for reference: TopicReference) async throws -> Document {
        do {
            print("DOCUMENT")
            let bundle = try bundle(for: reference.bundleIdentifier)
            var url = bundle.baseURL
            url.append(component: "data")
            url.append(path: reference.path.trimmingPrefix("/"))
            url.appendPathExtension("json")
            let data = try await dataProvider.contentsOfURL(url, in: bundle)
            let document = try JSONDecoder().decode(Document.self, from: data)
            return document
        } catch let error as DescribedError {
            print("document(for:) failed: "+error.errorDescription)
            throw error
        } catch {
            throw error
        }
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

