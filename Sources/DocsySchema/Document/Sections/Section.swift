
public protocol SectionProtocol: Decodable, Equatable {
    typealias Kind = SectionKind
    var kind: Kind { get }
}


public indirect enum AnyContentSection: TypedContainer, Equatable {
    public typealias Kind = SectionKind

    case discussion(ContentSection)
    case content(ContentSection)
    case taskGroup(TaskGroupSection)
    case relationships(RelationshipsSection)
    case declarations(DeclarationsSection)
    case parameters(ParametersSection)
    case attributes(AttributesSection)
    case properties(PropertiesSection)
    case restParameters(RESTParametersSection)
    case restEndpoint(RESTEndpointSection)
    case restBody(RESTBodySection)
    case restResponses(RESTResponseSection)
    case plistDetails(PlistDetailsSection)
    case possibleValues(PossibleValuesSection)
    case mentions(MentionsSection)

    public init(from decoder: any Decoder, as kind: SectionKind) throws {
        self = switch kind {
        case .discussion: .discussion(try ContentSection(from: decoder))
        case .content: .content(try ContentSection(from: decoder))
        case .taskGroup: .taskGroup(try TaskGroupSection(from: decoder))
        case .relationships: .relationships(try RelationshipsSection(from: decoder))
        case .declarations: .declarations(try DeclarationsSection(from: decoder))
        case .parameters: .parameters(try ParametersSection(from: decoder))
        case .attributes: .attributes(try AttributesSection(from: decoder))
        case .properties: .properties(try PropertiesSection(from: decoder))
        case .restParameters: .restParameters(try RESTParametersSection(from: decoder))
        case .restEndpoint: .restEndpoint(try RESTEndpointSection(from: decoder))
        case .restBody: .restBody(try RESTBodySection(from: decoder))
        case .restResponses: .restResponses(try RESTResponseSection(from: decoder))
        case .plistDetails: .plistDetails(try PlistDetailsSection(from: decoder))
        case .possibleValues: .possibleValues(try PossibleValuesSection(from: decoder))
        case .mentions: .mentions(try MentionsSection(from: decoder))
        default: fatalError()
        }
    }
}

//public extension ContentSection {
//    var kind: SectionKind { get }
//}

public protocol TypedContainer<Kind>: Decodable {
    static var kindKey: AnyCodingKey { get }
    associatedtype Kind: RawRepresentable where Kind.RawValue: Decodable

    init(from decoder: any Decoder, as kind: Kind) throws
}

extension TypedContainer {
    public static var kindKey: AnyCodingKey { AnyCodingKey(stringValue: "kind") }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)

        guard !container.allKeys.isEmpty else {
            throw DecodingError.typeMismatch(Self.self, .init(
                codingPath: decoder.codingPath,
                debugDescription: "TypedContainer requires at least one key '\(Self.kindKey.stringValue)'",
                underlyingError: nil
            ))
        }

        let rawKind: Kind.RawValue

        do {
            rawKind = try container.decode(Kind.RawValue.self, forKey: Self.kindKey)
        } catch let error as DecodingError{
            throw DecodingError.typeMismatch(Kind.RawValue.self, .init(
                codingPath: decoder.codingPath,
                debugDescription: "Failed to decode raw : \(error)",
                underlyingError: error
            ))
        }

        guard let kind = Kind(rawValue: rawKind) else {
            throw DecodingError.dataCorruptedError(
                forKey: Self.kindKey,
                in: container,
                debugDescription: "Cannot decode \(Kind.self) from '\(rawKind)'"
            )
        }

        try self.init(from: decoder, as: kind)
    }
}


public enum SectionKind: String, Codable, Equatable {
    // Article render sections
    case hero, intro, tasks, assessments, volume, contentAndMedia, contentAndMediaGroup, callToAction, tile, articleBody, resources

    // Symbol render sections
    case mentions, discussion, content, taskGroup, relationships, declarations, parameters, sampleDownload, row

    // Rest symbol sections
    case restParameters, restResponses, restBody, restEndpoint, properties

    // Plist
    case plistDetails = "details", attributes, possibleValues
}
