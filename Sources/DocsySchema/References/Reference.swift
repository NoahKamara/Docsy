import Foundation


/// A reference to a resource.
///
/// The reference can refer to a resource within a documentation bundle (e.g., another symbol) or an external resource (e.g., a web URL).
/// Check the conforming types to browse the different kinds of references.
public protocol ReferenceProtocol: Decodable, Sendable, Equatable {
    /// The type of the reference.
    var type: ReferenceType { get }

    /// The identifier of the reference.
    ///
    /// The identifier can be used to look up a value in the document's ``RenderNode/references`` dictionary.
    var identifier: ReferenceIdentifier { get }
}



/// The type of a reference.
public enum ReferenceType: String, Codable, Equatable, Sendable {
    case image, video, file, fileType, xcodeRequirement, topic, section, download, link, externalLocation
    case unresolvable
}

/// A reference to a resource.
///
/// The reference can refer to a resource within a documentation bundle (e.g., another symbol) or an external resource (e.g., a web URL).
/// Check the conforming types to browse the different kinds of references.
public enum Reference: Decodable, Sendable, Equatable {
    case image(ImageReference)
    case video(VideoReference)
    case file(FileReference)
    case fileType(FileTypeReference)
//    case xcodeRequirement
    case topic(TopicRenderReference)
//    case section(SectionRefere)
    case download(DownloadReference)
    case link(LinkReference)
//    case externalLocation
//    case unresolvable


    public init(from decoder: any Decoder) throws {
        enum CodingKeys: CodingKey {
            case type
        }


        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ReferenceType.self, forKey: .type)

        switch type {
        case .image:    self = try .image(.init(from: decoder))
        case .video:    self = try .video(.init(from: decoder))
        case .file:     self = try .file(.init(from: decoder))
        case .fileType: self = try .fileType(.init(from: decoder))
        case .topic:    self = try .topic(.init(from: decoder))
        case .link:     self = try .link(.init(from: decoder))
//        case .xcodeRequirement:
//        case .section:
        case .download: self = try .download(.init(from: decoder))
//        case .externalLocation:
//        case .unresolvable:
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Cannot decode reference of type '\(type)'")
        }
    }
}

/// A reference that has a file.
public protocol URLReference {
    /// The base URL that file URLs of the conforming type are relative to.
    static var baseURL: URL { get }
}

extension URLReference {
    /// Returns the URL for a given file path relative to the base URL of the conforming type.
    ///
    /// The converter that writes the built documentation to the file system is responsible for copying the referenced file to this destination.
    ///
    /// - Parameters:
    ///   - path: The path of the file.
    ///   - prefixComponent: An optional path component to add before the path of the file.
    /// - Returns: The destination URL for the given file path.
    func destinationURL(for path: String, prefixComponent: String?) -> URL {
        var url = Self.baseURL
        if let bundleName = prefixComponent {
            url.appendPathComponent(bundleName, isDirectory: true)
        }
        url.appendPathComponent(path, isDirectory: false)
        return url
    }
}


extension Reference: ReferenceProtocol {
    private var reference: any ReferenceProtocol {
        switch self {
        case .image(let ref): ref
        case .video(let ref): ref
        case .file(let ref): ref
        case .fileType(let ref): ref
//        case .xcodeRequirement(let ref): ref
        case .topic(let ref): ref
//        case .section(let ref): ref
        case .download(let ref): ref
        case .link(let ref): ref
//        case .externalLocation(let ref): ref
//        case .unresolvable(let ref): ref
        }
    }

    public var type: ReferenceType { reference.type }
    public var identifier: ReferenceIdentifier { reference.identifier }
}
