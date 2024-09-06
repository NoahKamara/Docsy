//
//  ParameterSection.swift
// Docsy
//
//  Copyright © 2024 Noah Kamara.
//

/// A section that contains a list of parameters.
public struct ParametersSection: SectionProtocol, Equatable {
    public var kind: Kind = .parameters
    /// The list of parameter sub-sections.
    public let parameters: [ParameterSection]

    /// Creates a new parameters section with the given list.
    public init(parameters: [ParameterSection]) {
        self.parameters = parameters
    }
}

/// A section that contains a single, named parameter.
public struct ParameterSection: Decodable, Equatable {
    /// The parameter name.
    public let name: String
    /// Free-form content to provide information about the parameter.
    public var content: [BlockContent]
}
