
public protocol SectionProtocol: Decodable, Equatable {
    typealias Kind = SectionKind

    var kind: Kind { get }
}

public enum SectionKind: String, Codable {
    // Article render sections
    case hero, intro, tasks, assessments, volume, contentAndMedia, contentAndMediaGroup, callToAction, tile, articleBody, resources

    // Symbol render sections
    case mentions, discussion, content, taskGroup, relationships, declarations, parameters, sampleDownload, row

    // Rest symbol sections
    case restParameters, restResponses, restBody, restEndpoint, properties

    // Plist
    case plistDetails = "details", attributes, possibleValues
}
