
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
        underlyingError = error
        customDescription = error.errorDescription
    }

    @_disfavoredOverload
    init(underlyingError error: any Error) {
        underlyingError = error
        customDescription = nil
    }
}
