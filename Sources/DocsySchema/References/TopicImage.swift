/// A custom authored image that can be associated with a documentation topic.
///
/// Allows an author to provide a custom icon or card image for a given documentation page.
public struct TopicImage: Codable, Hashable, Sendable {
    /// The type of this topic image.
    public let type: TopicImageType

    /// The reference identifier for the image.
    public let identifier: ReferenceIdentifier

    /// Create a new topic image with the given type and reference identifier.
    public init(
        type: TopicImage.TopicImageType,
        identifier: ReferenceIdentifier
    ) {
        self.type = type
        self.identifier = identifier
    }
}

extension TopicImage {
    /// The type of topic image.
    public enum TopicImageType: String, Codable, Hashable, Sendable {
        /// An icon image that should be used to represent this page wherever a default icon
        /// is currently used.
        case icon

        /// An icon image that should be used to represent this page wherever a default icon
        /// is currently used.
        case card
    }
}
