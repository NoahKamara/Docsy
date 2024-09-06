//
//  Hierarchy.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

public extension Document {
    /// Hierarchical information for a document.
    ///
    /// A document's hierarchy information, such as its parent topics,
    /// describes an API reference hierarchy that starts with a framework
    /// landing page, or a Tutorials hierarchy that starts with a Tutorials landing page.
    enum Hierarchy: Schema {
        /// The hierarchy for an API reference document.
        case reference(ReferenceHierarchy)
        /// The hierarchy for tutorials-related document.
        case tutorials(TutorialsHierarchy)

        public init(from decoder: Decoder) throws {
            if let tutorialsHierarchy = try? TutorialsHierarchy(from: decoder) {
                self = .tutorials(tutorialsHierarchy)
                return
            }

            let referenceHierarchy = try ReferenceHierarchy(from: decoder)
            self = .reference(referenceHierarchy)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .reference(let hierarchy):
                try container.encode(hierarchy)
            case .tutorials(let hierarchy):
                try container.encode(hierarchy)
            }
        }
    }

    // MARK: Reference

    struct ReferenceHierarchy: Codable, Equatable, Sendable {
        /// The paths (breadcrumbs) that lead from the landing page to the given symbol.
        ///
        /// A single path is a list of topic-graph references, that trace the curation
        /// through the documentation hierarchy from a framework landing page to a
        /// given target symbol.
        ///
        /// Symbols curated multiple times have multiple paths, for example:
        ///  - Example Framework / Example Type / Example Property
        ///  - Example Framework / My Article / Example Type / Example Property
        ///  - Example Framework / Related Type / Example Property
        /// > Note: The first element in `paths` is the _canonical_ breadcrumb for the symbol.
        ///
        /// Landing pages' hierarchy contains a single, empty path.
        public let paths: [[String]]

        public init(paths: [[String]]) {
            self.paths = paths
        }
    }

    // MARK: Tutorials

    struct TutorialsHierarchy: Codable, Equatable, Sendable {
        /// The topic reference for the landing page.
        public var reference: ReferenceIdentifier

        /// The chapters of the technology.
        public var modules: [Hierarchy.Chapter]?

        /// The paths to the current node.
        ///
        /// A list of render reference identifiers.
        public var paths: [[String]]

        private enum CodingKeys: CodingKey {
            case reference
            case modules
            case paths
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.reference = try container.decode(ReferenceIdentifier.self, forKey: .reference)
            self.modules = try container.decodeIfPresent([Hierarchy.Chapter].self, forKey: .modules)
            self.paths = try container.decode([[String]].self, forKey: .paths)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(reference, forKey: .reference)
            try container.encodeIfPresent(modules, forKey: .modules)
            try container.encode(paths, forKey: .paths)
        }
    }

    // MARK: Technologies

    struct TechnologiesHierarchy: Codable, Equatable, Sendable {
        /// The topic reference for the landing page.
        public var reference: ReferenceIdentifier

        /// The chapters of the technology.
        public var modules: [Hierarchy.Chapter]?

        /// The paths to the current node.
        ///
        /// A list of render reference identifiers.
        public var paths: [[String]]

        private enum CodingKeys: CodingKey {
            case reference
            case modules
            case paths
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.reference = try container.decode(ReferenceIdentifier.self, forKey: .reference)
            self.modules = try container.decodeIfPresent([Hierarchy.Chapter].self, forKey: .modules)
            self.paths = try container.decode([[String]].self, forKey: .paths)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(reference, forKey: .reference)
            try container.encodeIfPresent(modules, forKey: .modules)
            try container.encode(paths, forKey: .paths)
        }
    }
}
