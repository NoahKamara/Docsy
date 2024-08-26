/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021-2023 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

/// A reference to a URL.
public struct LinkReference: ReferenceProtocol, Equatable {
    /// The type of this link reference.
    ///
    /// This value is always `.link`.
    public var type: ReferenceType = .link
    
    /// The identifier of this reference.
    public var identifier: ReferenceIdentifier
    
    /// The plain text title of the destination page.
    public var title: String
    
    /// The formatted title of the destination page.
    public var titleInlineContent: [InlineContent]

    /// The topic url for the destination page.
    public var url: String
    

    enum CodingKeys: String, CodingKey {
        case type, identifier, title, titleInlineContent, url
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(ReferenceType.self, forKey: .type)
        identifier = try values.decode(ReferenceIdentifier.self, forKey: .identifier)
        
        let urlPath = try values.decode(String.self, forKey: .url)
        
        if let formattedTitle = try values.decodeIfPresent([InlineContent].self, forKey: .titleInlineContent) {
            self.titleInlineContent = formattedTitle
            self.title = try values.decodeIfPresent(String.self, forKey: .title) ?? formattedTitle.plainText
        } else if let plainTextTitle = try values.decodeIfPresent(String.self, forKey: .title) {
            self.titleInlineContent = [.text(plainTextTitle)]
            self.title = plainTextTitle
        } else {
            self.titleInlineContent = [.text(urlPath)]
            self.title = urlPath
        }
        
        url = urlPath
    }
}
