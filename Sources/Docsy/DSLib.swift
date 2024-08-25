//// The Swift Programming Language
//// https://docs.swift.org/swift-book
//
//
//
//public protocol DocumentationProvider {
//    var identifier: String { get }
//}
//
//
//import DocCArchive
//import Foundation
//
//public struct DocCArchiveProvider: DocumentationProvider {
//    public let identifier: String = UUID().uuidString
//
//    var archive: DocCArchive
//
//    init() throws {
//        let url = URL(fileURLWithPath: "/Users/noahkamara/Developer/DocSee/SlothCreator.doccarchive")
//        let archive = try DocCArchive(contentsOf: url)
//        print(archive)
//    }
//}
//
//public enum FSNode {
//    case file(URL)
//    case dir(URL, [FSNode])
//}
//
//DocCArchive(contentsOf: url)


import SwiftUI

