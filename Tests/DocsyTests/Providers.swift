//
//
//import Testing
//import Foundation
//@testable import Docsy
//
//@Suite("Providers")
//struct ProvidersTests {
//    @Test("Docsy Tests")
//    func localFSProvider() async throws {
//        let archiveURL = URL.init(filePath: "/Users/noahkamara/Developer/DocSee/docc.doccarchive")
//
//        let provider = try LocalFileSystemDataProvider(rootURL: archiveURL)
//
//        let bundles = try await provider.bundles()
//
//        let bundle = try #require(bundles.first)
//
//        #expect(bundle.identifier == "org.swift.docc")
//        #expect(bundle.displayName == "docc")
//    }
//}
