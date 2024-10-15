//
//  AssetReferences.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public extension Document {
    /// All image, video, file, and download references of this node, grouped by their type.
    var assetReferences: [ReferenceType: [Reference]] {
        let assetTypes = [ReferenceType.image, .video, .file, .download, .externalLocation]
        return .init(grouping: references.values.lazy.filter { assetTypes.contains($0.type) }, by: { $0.type })
    }
}
