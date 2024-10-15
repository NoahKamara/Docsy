//
//  SourceLanguage.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public struct SourceLanguage: Hashable, Codable, Equatable, Sendable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// The display name of the programming language.
    public var name: String

    /// A globally unique identifier for the language.
    public var id: String

    /// Aliases for the language's identifier.
    public var idAliases: [String] = []

    /// The identifier to use for link disambiguation purposes.
    public var linkDisambiguationID: String

    /// Creates a new language with a given name and identifier.
    /// - Parameters:
    ///   - name: The display name of the programming language.
    ///   - id: A globally unique identifier for the language.
    ///   - idAliases: Aliases for the language's identifier.
    ///   - linkDisambiguationID: The identifier to use for link disambiguation purposes.
    public init(name: String, id: String, idAliases: [String] = [], linkDisambiguationID: String? = nil) {
        self.name = name
        self.id = id
        self.idAliases = idAliases
        self.linkDisambiguationID = linkDisambiguationID ?? id
    }

    /// Finds the programming language that matches a given display name, or creates a new one if it finds no existing language.
    ///
    /// - Parameter name: The display name of the programming language.
    public init(name: String) {
        if let knownLanguage = SourceLanguage.firstKnownLanguage(withName: name) {
            self = knownLanguage
        } else {
            self.name = name

            let id = name.lowercased()
            self.id = id
            self.linkDisambiguationID = id
        }
    }

    /// Finds the programming language that matches a given display name.
    ///
    /// If the language name doesn't match any known language, this initializer returns `nil`.
    ///
    /// - Parameter knownLanguageName: The display name of the programming language.
    public init?(knownLanguageName: String) {
        if let knownLanguage = SourceLanguage.firstKnownLanguage(withName: knownLanguageName) {
            self = knownLanguage
        } else {
            return nil
        }
    }

    /// Finds the programming language that matches a given identifier.
    ///
    /// If the language identifier doesn't match any known language, this initializer returns `nil`.
    ///
    /// - Parameter knownLanguageIdentifier: The identifier name of the programming language.
    public init?(knownLanguageIdentifier: String) {
        if let knownLanguage = SourceLanguage.firstKnownLanguage(withIdentifier: knownLanguageIdentifier) {
            self = knownLanguage
        } else {
            return nil
        }
    }

    private static func firstKnownLanguage(withName name: String) -> SourceLanguage? {
        SourceLanguage.knownLanguages.first { $0.name.lowercased() == name.lowercased() }
    }

    private static func firstKnownLanguage(withIdentifier id: String) -> SourceLanguage? {
        SourceLanguage.knownLanguages.first { knownLanguage in
            ([knownLanguage.id] + knownLanguage.idAliases)
                .map { $0.lowercased() }
                .contains(id)
        }
    }

    enum CodingKeys: CodingKey {
        case name
        case id
        case idAliases
        case linkDisambiguationID
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SourceLanguage.CodingKeys.self)

        let name = try container.decode(String.self, forKey: SourceLanguage.CodingKeys.name)
        let id = try container.decode(String.self, forKey: SourceLanguage.CodingKeys.id)
        let idAliases = try container.decodeIfPresent([String].self, forKey: SourceLanguage.CodingKeys.idAliases) ?? []
        let linkDisambiguationID = try container.decodeIfPresent(String.self, forKey: SourceLanguage.CodingKeys.linkDisambiguationID)

        self.init(name: name, id: id, idAliases: idAliases, linkDisambiguationID: linkDisambiguationID)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SourceLanguage.CodingKeys.self)

        try container.encode(name, forKey: SourceLanguage.CodingKeys.name)
        try container.encode(id, forKey: SourceLanguage.CodingKeys.id)
        try container.encode(idAliases, forKey: SourceLanguage.CodingKeys.idAliases)
        try container.encode(linkDisambiguationID, forKey: SourceLanguage.CodingKeys.linkDisambiguationID)
    }

    public static func < (lhs: SourceLanguage, rhs: SourceLanguage) -> Bool {
        // Sort Swift before other languages.
        if lhs == .swift {
            return true
        } else if rhs == .swift {
            return false
        }
        // Otherwise, sort by ID for a stable order.
        return lhs.id < rhs.id
    }
}

// MARK: Known Languages

public extension SourceLanguage {
    /// The list of programming languages that are known to DocC.
    static let knownLanguages: [SourceLanguage] = [
        .bash,
        .c,
        .cpp,
        .css,
        .scss,
        .diff,
        .http,
        .java,
        .javascript,
        .json,
        .llvm,
        .markdown,
        .objective,
        .perl,
        .php,
        .python,
        .ruby,
        .shell,
        .swift,
        .xml,
        .metal,
    ]

    /// Finds the programming language that matches a given identifier, or creates a new one if it finds no existing language.
    /// - Parameter id: The identifier of the programming language.
    init(id: String) {
        switch id {
        case "bash", "sh", "zsh": self = .bash
        case "c", "h": self = .c
        case "cpp", "cc", "c++", "h++", "hpp", "hh", "hxx", "cxx": self = .cpp
        case "css": self = .css
        case "scss": self = .scss
        case "diff", "patch": self = .diff
        case "http", "https": self = .http
        case "java", "jsp": self = .java
        case "javascript", "js", "jsx", "mjs", "cjs": self = .javascript
        case "json": self = .json
        case "llvm": self = .llvm
        case "markdown", "md", "mkdown", "mkd": self = .markdown
        case "objective-c", "mm", "objc", "obj-c", "objectivec": self = .objective
        case "perl", "pl", "pm": self = .perl
        case "php": self = .php
        case "python", "py", "gyp", "ipython": self = .python
        case "ruby", "rb", "gemspec", "podspec", "thor", "irb": self = .ruby
        case "shell", "console", "shellsession": self = .shell
        case "swift": self = .swift
        case "xml", "html", "xhtml", "rss", "atom", "xjb", "xsd", "xsl", "plist", "wsf", "svg": self = .xml
        case "metal": self = .metal
        case "html, xhtml, rss, atom, xjb, xsd, xsl, plist, wsf, svg": self = .xml
        default:
            self.name = id
            self.id = id
            self.linkDisambiguationID = id
        }
    }

    /// The Bash shell scripting language.
    static let bash = SourceLanguage(name: "Bash", id: "bash", idAliases: ["sh", "zsh"])
    /// The C programming language.
    static let c = SourceLanguage(name: "C", id: "C", idAliases: ["h"])
    /// The C++ programming language.
    static let cpp = SourceLanguage(name: "C++", id: "C++", idAliases: ["cc", "c++", "h++", "hpp", "hh", "hxx", "cxx"])
    /// Cascading Style Sheets (CSS) for styling web pages.
    static let css = SourceLanguage(name: "CSS", id: "CSS")
    /// Sassy CSS (SCSS), a preprocessor scripting language that is interpreted or compiled into CSS.
    static let scss = SourceLanguage(name: "SCSS", id: "SCSS")
    /// A unified format for describing changes to text files.
    static let diff = SourceLanguage(name: "Diff", id: "diff", idAliases: ["patch"])
    /// The Hypertext Transfer Protocol (HTTP) used for transmitting web pages.
    static let http = SourceLanguage(name: "HTTP", id: "http", idAliases: ["https"])
    /// The Java programming language.
    static let java = SourceLanguage(name: "Java", id: "java", idAliases: ["jsp"])
    /// The JavaScript programming language.
    static let javascript = SourceLanguage(name: "JavaScript", id: "javascript", idAliases: ["js", "jsx", "mjs", "cjs"])
    /// JavaScript Object Notation (JSON) for data interchange.
    static let json = SourceLanguage(name: "JSON", id: "json")
    /// The LLVM compiler infrastructure project.
    static let llvm = SourceLanguage(name: "LLVM", id: "llvm")
    /// Markdown, a lightweight markup language for creating formatted text.
    static let markdown = SourceLanguage(name: "Markdown", id: "markdown", idAliases: ["md", "mkdown", "mkd"])
    /// The Objective-C programming language.
    static let objective = SourceLanguage(name: "Objective-C", id: "objectiv", idAliases: ["-c mm", "objc", "obj-c", "objectivec"])
    /// The Perl programming language.
    static let perl = SourceLanguage(name: "Perl", id: "perl", idAliases: ["pl", "pm"])
    /// The PHP programming language.
    static let php = SourceLanguage(name: "PHP", id: "php")
    /// The Python programming language.
    static let python = SourceLanguage(name: "Python", id: "python", idAliases: ["py", "gyp", "ipython"])
    /// The Ruby programming language.
    static let ruby = SourceLanguage(name: "Ruby", id: "ruby", idAliases: ["rb", "gemspec", "podspec", "thor", "irb"])
    /// Generic shell scripting.
    static let shell = SourceLanguage(name: "Shell", id: "shell", idAliases: ["console", "shellsession"])
    /// The Swift programming language.
    static let swift = SourceLanguage(name: "Swift", id: "swift")
    /// Extensible Markup Language (XML) and related formats.
    static let xml = SourceLanguage(name: "XML", id: "xml", idAliases: ["html", "xhtml", "rss", "atom", "xjb", "xsd", "xsl", "plist", "wsf", "svg"])
    /// The Metal programming language.
    static let metal = SourceLanguage(name: "Metal", id: "metal")
}
