/// A color that associated with a documentation topic.
public struct TopicColor: Codable, Hashable, Sendable {
    /// A context-dependent standard colors
    public enum StandardColor: String, Codable, Hashable, Sendable {
        case blue
        case gray
        case green
        case orange
        case purple
        case red
        case yellow
    }

    /// A string identifier for a built-in, standard color.
    ///
    /// > optional to allow for a future where topic colors can be
    /// > defined by something besides the standard color identifiers
    public let standardColorIdentifier: StandardColor?
}
