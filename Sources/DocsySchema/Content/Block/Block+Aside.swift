

// MARK: Aside
public extension BlockContent {
    /// An aside block.
    struct Aside: Equatable, Sendable, BlockContentProtocol {
        /// An appropriate display name for this aside
        public var displayName: String {
            customName ?? style.displayName
        }

        /// The style of this aside block.
        let customName: String?

        /// The style of this aside block.
        public var style: AsideStyle

        /// The content inside this aside block.
        public var content: [BlockContent]

        public init(
            displayName: String? = nil,
            style: AsideStyle,
            content: [BlockContent]
        ) {
            self.customName = displayName
            self.style = style
            self.content = content
        }

        init(from container: Container) throws {
            let customName = try container.decodeIfPresent(String.self, forKey: .name)
            let style = try container.decode(AsideStyle.self, forKey: .style)
            let content = try container.decode([BlockContent].self, forKey: .content)

            self.init(
                displayName: customName,
                style: style,
                content: content
            )
        }
    }

    /// A type the describes an aside style.
    enum AsideStyle: Decodable, Equatable, Sendable {
        case known(Known)
        case unknown(_ rawValue: String)

        public var rawValue: String {
            switch self {
            case .known(let known): known.rawValue
            case .unknown(let rawValue): rawValue
            }
        }

        /// an appropriate display name for this style
        public var displayName: String {
            switch self {
            case .known(let known): known.displayName
            case .unknown(let rawValue):
                if rawValue.contains(where: \.isUppercase) {
                    // If any character is upper-cased, assume the content has
                    // specific casing and return the raw value.
                    rawValue
                } else {
                    rawValue.capitalized
                }
            }
        }

        public enum Known: String, Equatable, Sendable, CaseIterable {
            case note = "Note"
            case tip = "Tip"
            case important = "Important"
            case experiment = "Experiment"
            case warning = "Warning"
            case attention = "Attention"
            case author = "Author"
            case authors = "Authors"
            case bug = "Bug"
            case complexity = "Complexity"
            case copyright = "Copyright"
            case date = "Date"
            case invariant = "Invariant"
            case mutatingVariant = "MutatingVariant"
            case nonMutatingVariant = "NonMutatingVariant"
            case postcondition = "Postcondition"
            case precondition = "Precondition"
            case remark = "Remark"
            case requires = "Requires"
            case since = "Since"
            case toDo = "ToDo"
            case version = "Version"
            case `throws` = "Throws"
            case seeAlso = "SeeAlso"

            public var displayName: String {
                switch self {
                case .invariant: "Invariant"
                case .mutatingVariant: "Mutating Variant"
                case .nonMutatingVariant: "Non-Mutating Variant"
                case .toDo: "To Do"
                case .seeAlso: "See Also"
                default: rawValue
                }
            }
        }

        public enum OutputStyle {
            case note
            case tip
            case experiment
            case important
            case warning
        }

        /// The style of aside to use when rendering.
        public var renderKind: OutputStyle {
            switch self {
            case .known(let known):
                switch known {
                case .note: .note
                case .tip: .tip
                case .experiment: .experiment
                case .important: .important
                case .warning: .warning
                default: .note
                }
            case .unknown: .note
            }
        }

        /// Creates an aside style for the specified raw value.
        /// - Parameter rawValue: The heading text to use when rendering this style of aside.
        init(rawValue: String) {
            self = if let known = Known(rawValue: rawValue) {
                .known(known)
            } else {
                .unknown(rawValue)
            }
        }

        /// Creates an aside style by decoding the specified decoder.
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self.init(rawValue: rawValue)
        }
    }
}

