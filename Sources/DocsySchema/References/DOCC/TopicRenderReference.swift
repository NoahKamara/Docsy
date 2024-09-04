/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021-2024 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

/// A reference to another page of documentation in the current context.
public struct TopicRenderReference: ReferenceProtocol, Equatable {
    /// The type of this reference.
    ///
    /// This value is always `.topic`.
    public var type: ReferenceType = .topic

    /// The identifier of the reference.
    public var identifier: ReferenceIdentifier

    /// The title of the destination page.
    public var title: String

    /// The topic url for the destination page.
    public var url: String

    /// The abstract of the destination page.
    public var abstract: [InlineContent]

    /// The kind of page that's referenced.
    public var kind: Document.Kind

    /// Whether the reference is required in its parent context.
    public var required: Bool

    /// The additional "role" assigned to the symbol, if any
    ///
    /// This value is `nil` if the referenced page is not a symbol.
    public var role: String?

    /// The abbreviated declaration of the symbol to display in links
    ///
    /// This value is `nil` if the referenced page is not a symbol.
    public var fragments: [DeclarationSection.Token]?

    /// The abbreviated declaration of the symbol to display in navigation
    ///
    /// This value is `nil` if the referenced page is not a symbol.
    public var navigatorTitle: [DeclarationSection.Token]?

    /// Information about conditional conformance for the symbol
    ///
    /// This value is `nil` if the referenced page is not a symbol.
    public var conformance: ConformanceSection?

    /// The estimated time to complete the topic.
    public var estimatedTime: String?

    /// Number of default implementations for the symbol
    ///
    /// This value is `nil` if the referenced page is not a symbol.
    public var defaultImplementationCount: Int?

    /// A value that indicates whether this symbol is built for a beta platform
    ///
    /// This value is `false` if the referenced page is not a symbol.
    public var isBeta: Bool
    /// A value that indicates whether this symbol is deprecated
    ///
    /// This value is `false` if the referenced page is not a symbol.
    public var isDeprecated: Bool

    /// The names and style for a reference to a property list key or entitlement key.
    public var propertyListKeyNames: PropertyListKeyNames?

    /// The display name and raw key name for a property list key or entitlement key and configuration about which "name" to use for links to this page.
    public struct PropertyListKeyNames: Equatable, Sendable {
        /// A style for how to render links to a property list key or an entitlement key.
        public var titleStyle: PropertyListTitleStyle?
        /// The raw key name of a property list key or entitlement key, for example "com.apple.enableDataAccess".
        public var rawKey: String?
        /// The human friendly display name for a property list key or entitlement key, for example, "Enables Data Access".
        public var displayName: String?
    }

    /// An optional list of text-based tags.
    public var tags: [Document.Tag]?

    /// Author provided images that represent this page.
    public var images: [TopicImage]

    enum CodingKeys: String, CodingKey {
        case type
        case identifier
        case title
        case url
        case abstract
        case kind
        case required
        case role
        case fragments
        case navigatorTitle
        case estimatedTime
        case conformance
        case beta
        case deprecated
        case defaultImplementations
        case propertyListTitleStyle = "titleStyle"
        case propertyListRawKey = "name"
        case propertyListDisplayName = "ideTitle"
        case tags
        case images
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(ReferenceType.self, forKey: .type)
        identifier = try values.decode(ReferenceIdentifier.self, forKey: .identifier)
        title = try values.decode(String.self, forKey: .title)
        url = try values.decode(String.self, forKey: .url)
        abstract = try values.decodeIfPresent([InlineContent].self, forKey: .abstract) ?? []

        // Provide backwards-compatibility for TopicRenderReferences that don't have a `kind` key.
        kind = try values.decodeIfPresent(Document.Kind.self, forKey: .kind) ?? .tutorial
        required = try values.decodeIfPresent(Bool.self, forKey: .required) ?? false
        role = try values.decodeIfPresent(String.self, forKey: .role)
        fragments = try values.decodeIfPresent([DeclarationSection.Token].self, forKey: .fragments)
        navigatorTitle = try values.decodeIfPresent([DeclarationSection.Token].self, forKey: .navigatorTitle)

        conformance = try values.decodeIfPresent(ConformanceSection.self, forKey: .conformance)
        estimatedTime = try values.decodeIfPresent(String.self, forKey: .estimatedTime)
        isBeta = try values.decodeIfPresent(Bool.self, forKey: .beta) ?? false
        isDeprecated = try values.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false
        defaultImplementationCount = try values.decodeIfPresent(
            Int.self, forKey: .defaultImplementations
        )
        let propertyListTitleStyle = try values.decodeIfPresent(
            PropertyListTitleStyle.self, forKey: .propertyListTitleStyle
        )
        let propertyListRawKey = try values.decodeIfPresent(
            String.self, forKey: .propertyListRawKey
        )
        let propertyListDisplayName = try values.decodeIfPresent(
            String.self, forKey: .propertyListDisplayName
        )
        if propertyListRawKey != nil || propertyListRawKey != nil || propertyListDisplayName != nil {
            propertyListKeyNames = PropertyListKeyNames(
                titleStyle: propertyListTitleStyle,
                rawKey: propertyListRawKey,
                displayName: propertyListDisplayName
            )
        }
        tags = try values.decodeIfPresent([Document.Tag].self, forKey: .tags)
        images = try values.decodeIfPresent([TopicImage].self, forKey: .images) ?? []
    }
}
