import Foundation

/// A compound section that contains a list of declaration sections.
public struct DeclarationsSection: SectionProtocol {
    public let kind: Kind

    /// The list of declaration sections.
    public let declarations: [DeclarationSection]
}


/// A section that contains a symbol declaration.
public struct DeclarationSection: Decodable, Equatable {
    /// The platforms this declaration applies to.
    public let platforms: [PlatformName?]

    /// The list of declaration tokens that make up the declaration.
    ///
    /// For example, the declaration "var x: Int?" is comprised of a:
    ///  - "var" keyword token
    ///  - " x: " string token
    ///  - an "Int?" type-identifier token
    public let tokens: [Token]

    /// The programming languages that this declaration uses.
    public let languages: [String]?

    /// A lexical token to use in declarations.
    ///
    /// A lexical token is a string with an associated meaning in source code.
    /// For example, `123` is represented as a single token of kind "number".
    public struct Token: Codable, Hashable, Equatable {
        /// The token text content.
        public var text: String
        /// The token programming kind.
        public let kind: Kind

        /// The list of all expected tokens in a declaration.
        public enum Kind: String, Codable, RawRepresentable {
            /// A known keyword, like "class" or "var".
            case keyword
            /// An attribute, for example, "@main".
            case attribute
            /// A numeric literal, like "1.25" or "0xff".
            case number
            /// A string literal.
            case string
            /// An identifier, for example a property or a function name.
            case identifier
            /// A type identifier, for example, an integer or raw data.
            case typeIdentifier
            /// A generic parameter in a function signature.
            case genericParameter
            /// A plain text, such as whitespace or punctuation.
            case text
            /// A parameter name to use inside a function body.
            case internalParam
            /// A parameter name to use when calling a function.
            case externalParam
            /// A label that precedes an identifier.
            case label
        }

        /// If the token is a known symbol, its identifier.
        ///
        /// This value can be used to look up more information in the render node's ``RenderNode/references`` object.
        public let identifier: String?

        /// If the token is a known symbol, its precise identifier as vended in the symbol graph.
        public let preciseIdentifier: String?

        /// The kind of highlight the token should be rendered with.
        public var highlight: Highlight?

        /// The kinds of highlights that can be applied to a token.
        public enum Highlight: String, Codable, RawRepresentable {
            /// A highlight representing generalized change, not specifically added or removed.
            case changed
        }

        /// Creates a new declaration token with optional identifier and precise identifier.
        /// - Parameters:
        ///   - text: The text content of the token.
        ///   - kind: The kind of the token.
        ///   - identifier: If the token refers to a known symbol, its identifier.
        ///   - preciseIdentifier: If the refers to a symbol, its precise identifier.
        public init(
            text: String,
            kind: Kind,
            identifier: String? = nil,
            preciseIdentifier: String? = nil,
            highlight: Highlight? = nil
        ) {
            self.text = text
            self.kind = kind
            self.identifier = identifier
            self.preciseIdentifier = preciseIdentifier
            self.highlight = highlight
        }

        // MARK: - Codable

        private enum CodingKeys: CodingKey {
            case text, kind, identifier, preciseIdentifier, highlight, otherDeclarations
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(text, forKey: .text)
            try container.encode(kind, forKey: .kind)
            try container.encodeIfPresent(identifier, forKey: .identifier)
            try container.encodeIfPresent(preciseIdentifier, forKey: .preciseIdentifier)
            try container.encodeIfPresent(highlight, forKey: .highlight)
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            text = try container.decode(String.self, forKey: .text)
            kind = try container.decode(Kind.self, forKey: .kind)
            preciseIdentifier = try container.decodeIfPresent(String.self, forKey: .preciseIdentifier)
            identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
            highlight = try container.decodeIfPresent(Highlight.self, forKey: .highlight)
        }
    }

    /// Declarations for other symbols that are related to this one, e.g. overloads.
    public struct OtherDeclarations: Codable, Equatable {
        /// A displayable declaration for a different symbol that is connected to this one.
        public struct Declaration: Codable, Equatable {
            /// The symbol's declaration tokens.
            public let tokens: [Token]

            /// The symbol's identifier.
            public let identifier: String

            /// Creates a new other declaration for a symbol that is connected to this one, e.g. an overload.
            public init(tokens: [Token], identifier: String) {
                self.tokens = tokens
                self.identifier = identifier
            }
        }
        /// The displayable declarations for this symbol's overloads.
        let declarations: [Declaration]
        /// The index where this symbol's declaration should be displayed (inserted) among the declarations.
        let displayIndex: Int

        /// Creates a group of declarations for symbols that are connected to this one, e.g. overloads.
        public init(declarations: [Declaration], displayIndex: Int) {
            self.declarations = declarations
            self.displayIndex = displayIndex
        }
    }

    /// The declarations for this symbol's overloads.
    public let otherDeclarations: OtherDeclarations?

    public enum CodingKeys: CodingKey {
        case tokens
        case platforms
        case languages
        case otherDeclarations
    }

    /// Creates a new declaration section.
    /// - Parameters:
    ///   - languages: The source languages to which this declaration applies.
    ///   - platforms: The platforms to which this declaration applies.
    ///   - tokens: The list of declaration tokens.
    ///   - otherDeclarations: The declarations for this symbol's overloads.
    public init(languages: [String]?, platforms: [PlatformName?], tokens: [Token], otherDeclarations: OtherDeclarations? = nil) {
        self.languages = languages
        self.platforms = platforms
        self.tokens = tokens
        self.otherDeclarations = otherDeclarations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tokens = try container.decode([Token].self, forKey: .tokens)
        platforms = try container.decode([PlatformName?].self, forKey: .platforms)
        languages = try container.decodeIfPresent([String].self, forKey: .languages)
        otherDeclarations = try container.decodeIfPresent(OtherDeclarations.self, forKey: .otherDeclarations)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DeclarationSection.CodingKeys.self)
        try container.encode(self.tokens, forKey: DeclarationSection.CodingKeys.tokens)
        try container.encode(self.platforms, forKey: DeclarationSection.CodingKeys.platforms)
        try container.encode(self.languages, forKey: DeclarationSection.CodingKeys.languages)
        try container.encodeIfPresent(self.otherDeclarations, forKey: DeclarationSection.CodingKeys.otherDeclarations)
    }
}
