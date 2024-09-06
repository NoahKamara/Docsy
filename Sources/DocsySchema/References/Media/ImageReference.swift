//
//  ImageReference.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// A reference to an image.
public struct ImageReference: MediaReference, URLReference, Equatable {
    /// The type of this image reference.
    ///
    /// This value is always `.image`.
    public let type: ReferenceType = .image

    /// The identifier of this reference.
    public let identifier: ReferenceIdentifier

    /// Alternate text for the image.
    ///
    /// This text helps screen-readers describe the image.
    public let altText: String?

    /// The data associated with this asset, including its variants.
    public let asset: DataAsset

    init(identifier: ReferenceIdentifier, altText: String? = nil, asset: DataAsset) {
        self.identifier = identifier
        self.altText = altText
        self.asset = asset
    }

    enum CodingKeys: String, CodingKey {
        case type
        case identifier
        case alt
        case variants
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try values.decode(ReferenceIdentifier.self, forKey: .identifier)
        self.altText = try values.decodeIfPresent(String.self, forKey: .alt)

        // rebuild the data asset
        var asset = DataAsset()
        let variants = try values.decode([VariantProxy].self, forKey: .variants)
        for variant in variants {
            asset.register(variant.url, with: DataTraitCollection(from: variant.traits), metadata: .init(svgID: variant.svgID))
        }
        self.asset = asset
    }

    /// The relative URL to the folder that contains all images in the built documentation output.
    public static let baseURL = URL(string: "/images/")!

    /// A codable proxy value that the image reference uses to serialize information about its asset variants.
    public struct VariantProxy: Decodable, Equatable {
        /// The URL to the file for this image variant.
        public var url: URL
        /// The traits of this image reference.
        public var traits: [String]
        /// The ID for the SVG that should be rendered for this variant.
        ///
        /// This value is `nil` for variants that are not SVGs and for SVGs that do not include ids.
        public var svgID: String?

        enum CodingKeys: String, CodingKey {
            case size
            case url
            case traits
            case svgID
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.url = try values.decode(URL.self, forKey: .url)
            self.traits = try values.decode([String].self, forKey: .traits)
            self.svgID = try values.decodeIfPresent(String.self, forKey: .svgID)
        }
    }
}
