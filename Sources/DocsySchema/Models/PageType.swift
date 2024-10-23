//
//  PageType.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public enum PageType: String, Codable, Sendable {
    case root
    case article
    case tutorial = "project"
    case section
    case learn
    case overview
    case resources
    case symbol
    case framework = "module"
    case `class`
    case structure = "struct"
    case `protocol`
    case enumeration = "enum"
    case function = "func"
    case `extension`
    case variable = "var"
    case typeAlias = "typealias"
    case associatedType = "associatedtype"
    case `operator` = "op"
    case macro
    case union
    case enumerationCase = "case"
    case initializer = "init"
    case instanceMethod = "method"
    case instanceProperty = "property"
    case `subscript`
    case typeMethod
    case typeProperty
    case buildSetting
    case propertyListKey
    case sampleCode
    case httpRequest
    case dictionarySymbol
    case namespace
    case propertyListKeyReference
    case languageGroup
    case container
    case groupMarker

    // Custom
    case leaf
}
