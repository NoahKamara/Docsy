//
//  MediaReference.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

/// A reference to media, such as an image or a video.
public protocol MediaReference: ReferenceProtocol {
    /// The data associated with this asset, including its variants.
    var asset: DataAsset { get }
    /// Alternate text for the media.
    ///
    /// This text helps screen readers describe the media.
    var altText: String? { get }
}
