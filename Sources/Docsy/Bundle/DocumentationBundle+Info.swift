
public extension DocumentationBundle {
    struct Metadata: Codable, Equatable, Sendable {
        /// The display name of the bundle.
        public var displayName: String

        /// The unique identifier of the bundle.
        public var identifier: String

//        /// The unique identifier of the bundle.
//        public var identifier: String

        enum CodingKeys: String, CodingKey {
            case displayName = "bundleDisplayName"
            case identifier = "bundleIdentifier"
        }
    }
}
