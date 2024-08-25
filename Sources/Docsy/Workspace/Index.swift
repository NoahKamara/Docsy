////
////  File.swift
////  Docsy
////
////  Created by Noah Kamara on 24.08.24.
////
//
//import Foundation
//
//public struct Index {
//    public let includedArchiveIdentifiers: [String]
//    public let interfaceLanguages: InterfaceLanguages
//    public let references: References
//    public let schemaVersion: SchemaVersion
//
//    public init(includedArchiveIdentifiers: [String], interfaceLanguages: InterfaceLanguages, references: References, schemaVersion: SchemaVersion) {
//        self.includedArchiveIdentifiers = includedArchiveIdentifiers
//        self.interfaceLanguages = interfaceLanguages
//        self.references = references
//        self.schemaVersion = schemaVersion
//    }
//}
//
//// MARK: - InterfaceLanguages
//public struct InterfaceLanguages {
//    public let swift: [Swift]
//
//    public init(swift: [Swift]) {
//        self.swift = swift
//    }
//}
//
//// MARK: - Swift
//public struct Swift {
//    public let children: [SwiftChild]
//    public let path: String
//    public let title: String
//    public let type: String
//    public let icon: String?
//
//    public init(children: [SwiftChild], path: String, title: String, type: String, icon: String?) {
//        self.children = children
//        self.path = path
//        self.title = title
//        self.type = type
//        self.icon = icon
//    }
//}
//
//// MARK: - FluffyChild
//public struct FluffyChild {
//    public let title: String
//    public let type: PurpleType
//    public let path: String?
//    public let children: [SwiftChild]?
//    public let deprecated: Bool?
//
//    public init(title: String, type: PurpleType, path: String?, children: [SwiftChild]?, deprecated: Bool?) {
//        self.title = title
//        self.type = type
//        self.path = path
//        self.children = children
//        self.deprecated = deprecated
//    }
//}
//
//// MARK: - PurpleChild
//public struct PurpleChild {
//    public let title: String
//    public let type: FluffyType
//    public let path: String?
//    public let children: [FluffyChild]?
//
//    public init(title: String, type: FluffyType, path: String?, children: [FluffyChild]?) {
//        self.title = title
//        self.type = type
//        self.path = path
//        self.children = children
//    }
//}
//
//// MARK: - SwiftChild
//public struct SwiftChild {
//    public let title: String
//    public let type: String
//    public let path: String?
//    public let children: [PurpleChild]?
//
//    public init(title: String, type: String, path: String?, children: [PurpleChild]?) {
//        self.title = title
//        self.type = type
//        self.path = path
//        self.children = children
//    }
//}
//
//public enum PurpleType: String {
//    case groupMarker
//    case method
//    case op
//    case property
//    case symbol
//    case typeCase
//    case typeInit
//}
//
//public enum FluffyType: String {
//    case groupMarker
//    case method
//    case property
//    case symbol
//    case typeEnum
//    case typeExtension
//    case typeInit
//    case typeProtocol
//}
//
//// MARK: - References
//public struct References {
//    public let slothCreatorIconPNG: SlothCreatorIconPNG
//
//    public init(slothCreatorIconPNG: SlothCreatorIconPNG) {
//        self.slothCreatorIconPNG = slothCreatorIconPNG
//    }
//}
//
//// MARK: - SlothCreatorIconPNG
//public struct SlothCreatorIconPNG: Codable {
//    public let alt: String
//    public let identifier: String
//    public let type: String
//    public let variants: [Variant]
//
//    public init(alt: String, identifier: String, type: String, variants: [Variant]) {
//        self.alt = alt
//        self.identifier = identifier
//        self.type = type
//        self.variants = variants
//    }
//}
//
//// MARK: - Variant
//public struct Variant: Codable {
//    public let traits: [String]
//    public let url: String
//
//    public init(traits: [String], url: String) {
//        self.traits = traits
//        self.url = url
//    }
//}
//
//// MARK: - SchemaVersion
//public struct SchemaVersion: Codable {
//    public let major: Int
//    public let minor: Int
//    public let patch: Int
//
//    public init(major: Int, minor: Int, patch: Int) {
//        self.major = major
//        self.minor = minor
//        self.patch = patch
//    }
//}
