//
//  UnresolvedReference.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

/// A reference to another page which cannot be resolved.
public struct UnresolvedRenderReference: ReferenceProtocol, Equatable {
    /// The type of this unresolvable reference.
    ///
    /// This value is always `.unresolvable`.
    public var type: ReferenceType = .unresolvable

    /// The identifier of this unresolved reference.
    public var identifier: ReferenceIdentifier

    /// The title of this unresolved reference.
    public var title: String

    /// Creates a new unresolved reference with a given identifier and title.
    ///
    /// - Parameters:
    ///   - identifier: The identifier of this unresolved reference.
    ///   - title: The title of this unresolved reference.
    public init(identifier: ReferenceIdentifier, title: String) {
        self.identifier = identifier
        self.title = title
    }

    enum CodingKeys: CodingKey {
        case type
        case identifier
        case title
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try values.decode(ReferenceType.self, forKey: .type)
        self.identifier = try values.decode(ReferenceIdentifier.self, forKey: .identifier)
        self.title = try values.decode(String.self, forKey: .title)
    }
}
