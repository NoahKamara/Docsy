import Foundation
import Testing

struct TestCase<T: Decodable & Sendable>: Sendable, CustomStringConvertible, CustomTestStringConvertible, CustomDebugStringConvertible {
    var testDescription: String {
        title+" \(T.self)"
    }

    var description: String { title }

    var debugDescription: String {
        "TestCase(\(title), file='\(sourceLocation.fileName)', line=\(sourceLocation.line)"
    }

    let title: String
    let json: JSONValue
    let value: T
    let sourceLocation: SourceLocation

    init(
        sourceLocation: SourceLocation = #_sourceLocation,
        title: String,
        json: JSONValue,
        value: T
    ) {
        self.title = title
        self.json = json
        self.value = value
        self.sourceLocation = sourceLocation
    }

    init(_ title: String, json: () -> JSONValue, value: () -> T) {
        self.init(title: title, json: json(), value: value())
    }

    func decode() throws -> T {
        let data = try json.data()
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            Issue.record(error, "Failed to decode TestCase at \(self.debugDescription)").sourceLocation
            throw error
        }
    }
}

struct JSONValue: ExpressibleByStringInterpolation {
    let rawValue: String

    init(stringLiteral value: StaticString) {
        self.rawValue = value.description
    }

    init(stringInterpolation: StringInterpolation) {
        self.rawValue = stringInterpolation.result
    }

    struct StringInterpolation: StringInterpolationProtocol {
        var result = ""

        init(literalCapacity: Int, interpolationCount: Int) {}

        mutating func appendLiteral(_ literal: StaticString) {
            result.append(literal.description)
        }

        mutating func appendInterpolation(literal: String) {
            result.append(literal)
        }

        mutating func appendInterpolation(_ json: JSONValue) {
            appendInterpolation(literal: json.rawValue)
        }

        mutating func appendInterpolation(_ json: any JSONValueRepresentable) {
            appendInterpolation(json.jsonValue)
        }

        mutating func appendInterpolation<T: JSONValueRepresentable>(_ jsonOptional: T?) {
            if let jsonOptional {
                appendInterpolation(jsonOptional)
            } else {
                appendInterpolation(literal: "null")
            }
        }

        mutating func appendInterpolation<T: JSONValueRepresentable>(_ jsonArray: [T]) {
            let contents = jsonArray.map(\.jsonValue.rawValue).joined(separator: ",")
            appendInterpolation(literal: "[" + contents + "]")
        }
    }

    func data() throws -> Data {
        let data = rawValue.data(using: .utf8)!
        do {
            try JSONSerialization.jsonObject(with: data)
        } catch {
            print("Invalid JSON Value: ")
            print(rawValue)
            throw error
        }
        return data
    }
}

extension TestCase: JSONValueRepresentable {
    var jsonValue: JSONValue {
        json
    }
}

protocol JSONValueRepresentable {
    var jsonValue: JSONValue { get }
}

extension Int: JSONValueRepresentable {
    var jsonValue: JSONValue { "\(literal: self.description)" }
}

extension String: JSONValueRepresentable {
    var jsonValue: JSONValue {
        return "\"\(literal: self)\""
    }
}

extension Bool: JSONValueRepresentable {
    var jsonValue: JSONValue {
        self ? "true" : "false"
    }
}

extension Sequence where Element: JSONValueRepresentable {
    var jsonValue: JSONValue {
        "[\(literal: map(\.jsonValue.rawValue).joined(separator: ","))]"
//        "[" + map(\.jsonValue).joined(separator: ",") + "]"
    }
}

extension Dictionary where Key == String, Value: JSONValueRepresentable {
    var jsonValue: JSONValue {
        "{\(literal: map({ "\($0.key): \($0.value)" }).joined(separator: ",") )}"
    }
}

extension Optional where Wrapped: JSONValueRepresentable {
    var jsonValue: JSONValue {
        self?.jsonValue ?? "null"
    }
}



