import Foundation

/// A reference to a resource that can be downloaded.
public struct DownloadReference: ReferenceProtocol, URLReference, Equatable {
    /// The name you use for the directory that contains download items.
    ///
    /// This is the name of the directory within the generated build folder
    /// that contains downloads.
    public static let locationName = "downloads"

    public static let baseURL = URL(string: "/\(locationName)/")!

    public var type: ReferenceType = .download

    public var identifier: ReferenceIdentifier

    /// The location of the downloadable resource.
    public var url: URL

    /// Indicates whether the ``url`` property should be encoded verbatim into Render JSON.
    ///
    /// This is used during encoding to determine whether to filter ``url`` through the
    /// `renderURL(for:)` method. In case the URL was loaded from JSON, we don't want to modify it
    /// further after a round-trip.
    private var encodeUrlVerbatim = false

    /// The SHA512 hash value for the resource.
    public var checksum: String?

    enum CodingKeys: CodingKey {
        case type
        case identifier
        case url
        case checksum
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(ReferenceType.self, forKey: .type)
        identifier = try container.decode(ReferenceIdentifier.self, forKey: .identifier)
        url = try container.decode(URL.self, forKey: .url)
        encodeUrlVerbatim = true
        checksum = try container.decodeIfPresent(String.self, forKey: .checksum)
    }

    public static func == (lhs: DownloadReference, rhs: DownloadReference) -> Bool {
        lhs.identifier == rhs.identifier
            && lhs.url == rhs.url
            && lhs.checksum == rhs.checksum
    }
}

// extension DownloadReference {
//    private func renderURL(for url: URL, prefixComponent: String?) -> URL {
//        url.isAbsoluteWebURL ? url : destinationURL(for: url.lastPathComponent, prefixComponent: prefixComponent)
//    }
// }
