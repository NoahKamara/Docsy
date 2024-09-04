/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021-2023 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

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
        type = try values.decode(ReferenceType.self, forKey: .type)
        identifier = try values.decode(ReferenceIdentifier.self, forKey: .identifier)
        title = try values.decode(String.self, forKey: .title)
    }
}
