/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021-2024 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import Foundation

/// A reference to a video.
public struct VideoReference: MediaReference, URLReference, Equatable {
    /// The type of this video reference.
    ///
    /// This value is always `.video`.
    public let type: ReferenceType = .video

    /// The identifier of this reference.
    public let identifier: ReferenceIdentifier

    /// Alternate text for the video.
    ///
    /// This text helps screen readers describe the video.
    public let altText: String?

    /// The data associated with this asset, including its variants.
    public let asset: DataAsset

    /// The reference to a poster image for this video.
    public let poster: ReferenceIdentifier?

    init(identifier: ReferenceIdentifier, altText: String? = nil, asset: DataAsset, poster: ReferenceIdentifier? = nil) {
        self.identifier = identifier
        self.altText = altText
        self.asset = asset
        self.poster = poster
    }

    enum CodingKeys: String, CodingKey {
        case type
        case identifier
        case alt
        case variants
        case poster
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(ReferenceIdentifier.self, forKey: .identifier)
        altText = try values.decodeIfPresent(String.self, forKey: .alt)

        // rebuild the data asset
        var asset = DataAsset()
        let variants = try values.decode([VariantProxy].self, forKey: .variants)
        for variant in variants {
            asset.register(variant.url, with: DataTraitCollection(from: variant.traits))
        }
        self.asset = asset

        poster = try values.decodeIfPresent(ReferenceIdentifier.self, forKey: .poster)
    }

    /// The relative URL to the folder that contains all images in the built documentation output.
    public static let baseURL = URL(string: "/videos/")!

    /// A codable proxy value that the video reference uses to serialize information about its asset variants.
    public struct VariantProxy: Decodable, Equatable {
        /// The URL to the file for this video variant.
        public var url: URL
        /// The traits of this video reference.
        public var traits: [String]

        enum CodingKeys: String, CodingKey {
            case size
            case url
            case traits
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            url = try values.decode(URL.self, forKey: .url)
            traits = try values.decode([String].self, forKey: .traits)
        }
    }
}
