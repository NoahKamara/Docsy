
/// A section that contains a list of generic constraints for a symbol.
///
/// The section contains a list of generic constraints that describe the conditions
/// when a symbol is available or conforms to a protocol. For example:
/// "Available when `Element` conforms to `Equatable` and `S` conforms to `StringLiteral`."
public struct ConformanceSection: Decodable, Equatable, Sendable {
    /// A prefix with which to prepend availability constraints.
    var availabilityPrefix: [InlineContent] = [.text("Available when")]

    /// A prefix with which to prepend conformance constraints.
    var conformancePrefix: [InlineContent] = [.text("Conforms when")]

    /// The section constraints rendered as inline content.
    let constraints: [InlineContent]

    /// Additional parameters to consider when rendering conformance constraints.
    struct ConstraintRenderOptions {
        /// Whether the symbol is a leaf symbol, such as a function or a property.
        let isLeaf: Bool

        /// The name of the parent symbol.
        let parentName: String?

        /// The symbol name of `Self`.
        let selfName: String
    }

    private static let selfPrefix = "Self."

    /// Returns, modified if necessary, a conforming type's name for rendering.
    static func displayNameForConformingType(_ typeName: String) -> String {
        if typeName.hasPrefix(selfPrefix) {
            return String(typeName.dropFirst(selfPrefix.count))
        }
        return typeName
    }

    /// Filters the list of constraints to the significant constraints only.
    ///
    /// This method removes symbol graph constraints on `Self` that are always fulfilled.
    static func filterConstraints(_ constraints: [Constraint], options: ConstraintRenderOptions) -> [Constraint] {
        return constraints
            .filter { constraint -> Bool in
                if options.isLeaf {
                    // Leaf symbol.
                    if constraint.leftTypeName == "Self" && constraint.rightTypeName == options.parentName {
                        // The Swift compiler will sometimes include a constraint's to `Self`'s type,
                        // filter those generic constraints out.
                        return false
                    }
                    return true
                } else {
                    // Non-leaf symbol.
                    if constraint.leftTypeName == "Self" && constraint.rightTypeName == options.selfName {
                        // The Swift compiler will sometimes include a constraint's to `Self`'s type,
                        // filter those generic constraints out.
                        return false
                    }
                    return true
                }
            }
    }

    /// Groups all input requirements into a single multipart requirement.
    ///
    /// For example, converts the following repetitive constraints:
    /// ```
    /// Key conforms to Hashable, Key conforms to Equatable, Key conforms to Codable
    /// ```
    /// to the shorter version of:
    /// ```
    /// Key conforms to Hashable, Equatable, and Codable
    /// ```
    /// All requirements must be on the same type and with the same
    /// relation kind, for example, "is a" or "conforms to". The `conformances` parameter
    /// contains at least one requirement.
    static func groupRequirements(_ constraints: [Constraint]) -> [InlineContent] {
#warning("commented out")
        //            precondition(!constraints.isEmpty)
        //
        //            let constraintTypeNames = constraints.map { constraint in
        //                return InlineContent.codeVoice(code: constraint.rightTypeName)
        //            }
        //            let separators = NativeLanguage.english.listSeparators(itemsCount: constraints.count, listType: .union)
        //                .map { return InlineContent.text($0) }
        //
        //            let constraintCompoundName = zip(constraintTypeNames, separators).flatMap { [$0, $1] }
        //            + constraintTypeNames[separators.count...]
        //
        //            return [
        //                InlineContent.codeVoice(code: ConformanceSection.displayNameForConformingType(constraints[0].leftTypeName)),
        //                InlineContent.text(constraints[0].kind.spelling.spaceDelimited)
        //            ] + constraintCompoundName
        return []
    }
}

private extension String {
    /// Returns the string surrounded by spaces.
    var spaceDelimited: String { return " \(self) "}
}


/// SymbolGraph.Symbol.Swift.GenericConstraint
public struct Constraint: Codable, Hashable {
    public enum Kind: String, Codable {
        /**
         A conformance constraint, such as:

         ```swift
         extension Thing where Thing.T: Sequence {
         // ...
         }
         ```
         */
        case conformance

        /**
         A superclass constraint, such as:

         ```swift
         extension Thing where Thing.T: NSObject {
         // ...
         }
         ```
         */
        case superclass

        /**
         A same-type constraint, such as:

         ```swift
         extension Thing where Thing.T == Int {
         // ...
         }
         ```
         */
        case sameType
    }

    enum CodingKeys: String, CodingKey {
        case kind
        case leftTypeName = "lhs"
        case rightTypeName = "rhs"
    }

    /**
     The kind of generic constraint.
     */
    public var kind: Kind

    /**
     The spelling of the left-hand side of the constraint.
     */
    public var leftTypeName: String

    /**
     The spelling of the right-hand side of the constraint.
     */
    public var rightTypeName: String

    /// Create a new GenericConstraint for the given kind and type names.
    public init(kind: Kind, leftTypeName: String, rightTypeName: String) {
        self.kind = kind
        self.leftTypeName = leftTypeName
        self.rightTypeName = rightTypeName
    }

    /// Create a new GenericConstraint by decoding a native format.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(Kind.self, forKey: .kind)
        leftTypeName = try container.decode(String.self, forKey: .leftTypeName)
        rightTypeName = try container.decode(String.self, forKey: .rightTypeName)
    }

    /// Encode a GenericConstraint to a native format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encode(leftTypeName, forKey: .leftTypeName)
        try container.encode(rightTypeName, forKey: .rightTypeName)
    }
}


extension Constraint.Kind {
    /// The spelling to use when rendering this kind of constraint.
    var spelling: String {
        switch self {
        case .conformance: return "conforms to"
        case .sameType: return "is"
        case .superclass: return "inherits"
        }
    }
}
