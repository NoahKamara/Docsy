import Foundation

/// A section of documentation content.
public struct ContentSection: SectionProtocol, Equatable {
    public let kind: SectionKind

    /// Arbitrary content for this section.
    public var content: [BlockContent]
}
