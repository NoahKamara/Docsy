//
//  DescribedError.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation

public protocol DescribedError: Error {
    var errorDescription: String { get }
}

// public extension Error {
//    var errorDescription: String? {
//        (self as? any DescribedError)?.errorDescription
//    }
// }

struct AnyDescribedError: DescribedError {
    let underlyingError: any Error
    private let customDescription: String?

    var errorDescription: String {
        customDescription ?? "\(underlyingError)"
    }

    @_disfavoredOverload
    init(underlyingError error: some DescribedError) {
        self.underlyingError = error
        self.customDescription = error.errorDescription
    }

    @_disfavoredOverload
    init(underlyingError error: any Error) {
        self.underlyingError = error
        self.customDescription = nil
    }
}
