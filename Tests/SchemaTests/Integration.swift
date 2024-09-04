//
//  Integration.swift
//  Docsy
//
//  Created by Noah Kamara on 28.08.24.
//

import DocsySchema
import Foundation
import Testing
import TestResources

@Suite("Integration")
struct IntegrationTests {
    let decoder = JSONDecoder()

    @Test("SwiftDocC", arguments: [documents(of: Resources.docc).first!])
    func docc(documentURL: DoccArchiveURL) throws {
        let data = try Data(contentsOf: documentURL.url)
        _ = try decoder.decode(Document.self, from: data)
    }

    @Test("SlothCreator", arguments: [documents(of: Resources.slothCreator).first!])
    func sloth(documentURL: DoccArchiveURL) throws {
        let data = try Data(contentsOf: documentURL.url)
        _ = try decoder.decode(Document.self, from: data)
    }
}

struct DoccArchiveURL: CustomTestStringConvertible {
    var testDescription: String {
        let path = url
            .pathComponents
            .drop(while: { $0 != "data" })
            .dropFirst()
            .joined(separator: "/")

        return "\(url.lastPathComponent) - \(url)"
    }

    let url: URL

    init(_ url: URL) {
        self.url = url
    }
}

func documents(of doccArchiveURL: URL) -> [DoccArchiveURL] {
    let enumerator = FileManager.default.enumerator(
        at: doccArchiveURL.appending(components: "data"),
        includingPropertiesForKeys: nil
    )

    guard let enumerator else {
        return []
    }
    var documentURLs: [DoccArchiveURL] = []
    print(doccArchiveURL.path())

    while let fileURL = enumerator.nextObject() as? URL {
        if fileURL.pathExtension == "json" {
            documentURLs.append(DoccArchiveURL(fileURL))
        }
    }

    return documentURLs
}
