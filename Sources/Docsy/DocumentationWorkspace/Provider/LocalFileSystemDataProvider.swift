//
//  LocalFileSystemDataProvider.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public enum LocalFileSystemDataProviderError: DescribedError {
    case rootIsNotDirectory(URL)

    public var errorDescription: String {
        switch self {
        case .rootIsNotDirectory(let url):
            "root url is not a directory: '\(url.path())'"
        }
    }
}

public struct LocalFileSystemDataProvider: DataProvider {
    public let identifier: String = UUID().uuidString

    let rootURL: URL

    /// Creates a new provider that recursively traverses the content of the given root URL to discover documentation bundles.
    /// - Parameter rootURL: The location that this provider searches for documentation bundles in.
    public init(
        rootURL: URL,
        allowArbitraryCatalogDirectories: Bool = false,
        fileManager: FileManager = .default
    ) throws {
        let rootURL = rootURL.absoluteURL
        guard allowArbitraryCatalogDirectories || fileManager.directoryExists(atPath: rootURL.path()) else {
            throw LocalFileSystemDataProviderError.rootIsNotDirectory(rootURL)
        }

        self.rootURL = rootURL
    }

    public func contentsOfURL(_ url: consuming URL) throws -> Data {
        precondition(url.isFileURL, "Unexpected non-file url '\(url)'.")
        return try Data(contentsOf: url)
    }

    public func bundles() throws -> [DocumentationBundle] {
        try bundles(fileManager: .default)
    }

    public func bundles(fileManager: FileManager) throws -> [DocumentationBundle] {
        print(rootURL)
        guard rootURL.pathExtension != "doccarchive" else {
            let rootBundle = try createBundle(at: rootURL)
            return [rootBundle]
        }

        guard let files = fileManager.enumerator(at: rootURL, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return []
        }

        var bundles: [DocumentationBundle] = []

        while let fileURL = files.nextObject() as? URL {
            guard fileURL.pathExtension == "doccarchive" else {
                continue
            }

            let bundle = try createBundle(at: fileURL)
            bundles.append(bundle)
            files.skipDescendants()
        }

        return bundles
    }

    fileprivate func createBundle(at url: URL) throws -> DocumentationBundle {
        let metadataData = try Data(contentsOf: url.appending(components: "metadata.json"))

        let decoder = JSONDecoder()

        let metadata = try decoder.decode(DocumentationBundle.Metadata.self, from: metadataData)

        return DocumentationBundle(
            info: metadata,
            baseURL: url,
            indexURL: url.appending(components: "index", "index.json")
        )
    }
}

package extension FileManager {
    /// Returns a Boolean value that indicates whether a directory exists at a specified path.
    func directoryExists(atPath path: String) -> Bool {
        var isDirectory = ObjCBool(booleanLiteral: false)
        let fileExistsAtPath = fileExists(atPath: path, isDirectory: &isDirectory)
        return fileExistsAtPath && isDirectory.boolValue
    }

    // This method does n't exist on `FileManager`. There is a similar looking method but it doesn't provide information about potential errors.
    func contents(of url: URL) throws -> Data {
        try Data(contentsOf: url)
    }
}
