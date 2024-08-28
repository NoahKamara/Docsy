
import Foundation

public struct MentionsSection: SectionProtocol, Codable, Equatable {
    public var kind: Kind = .mentions
    public var mentions: [URL]

    public init(mentions: [URL]) {
        self.mentions = mentions
    }
}
