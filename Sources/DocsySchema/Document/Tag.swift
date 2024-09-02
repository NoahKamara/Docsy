
import Foundation

public extension Document {
    /// A tag that can be assigned to a Document.
    struct Tag: Codable, Equatable, Sendable {
        /// The tag type.
        let type: String
        /// The text to display.
        let text: String

        /// A pre-defined SPI tag.
        static let spi = Tag(type: "spi", text: "SPI")
    }
}
