
import Foundation

public struct LocalFileSystemDataProvider: DataProvider {
    public let identifier: String = UUID().uuidString

    let rootURL: URL

    /// Creates a new provider that recursively traverses the content of the given root URL to discover documentation bundles.
    /// - Parameter rootURL: The location that this provider searches for documentation bundles in.
    public init(rootURL: URL, fileManager: FileManager = .default) throws {
        guard fileManager.directoryExists(atPath: rootURL.path()) else {
            fatalError("requires directory")
        }

        self.rootURL = rootURL
    }


    public func contentsOfURL(_ url: URL) async throws -> Data {
        precondition(url.isFileURL, "Unexpected non-file url '\(url)'.")

        let rootPath = rootURL.path()
        let path = url.path()

        precondition(url.path().starts(with: rootURL.path()), "Expected subpath of '\(rootPath)' but got '\(path)'")

        return try Data(contentsOf: url)
    }

    public func bundles() throws -> [DocumentationBundle] {
        try bundles(fileManager: .default)
    }

    public func bundles(fileManager: FileManager) throws -> [DocumentationBundle] {
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

            do {
                let bundle = try createBundle(at: fileURL)
                bundles.append(bundle)
            } catch let error {
                print(error)
            }
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
            indexURL: url.appending(components: "index", "index.json")
        )
    }
}



extension FileManager {
    /// Returns a Boolean value that indicates whether a directory exists at a specified path.
    package func directoryExists(atPath path: String) -> Bool {
        var isDirectory = ObjCBool(booleanLiteral: false)
        let fileExistsAtPath = fileExists(atPath: path, isDirectory: &isDirectory)
        return fileExistsAtPath && isDirectory.boolValue
    }

    // This method doesn't exist on `FileManager`. There is a similar looking method but it doesn't provide information about potential errors.
    package func contents(of url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }
}
