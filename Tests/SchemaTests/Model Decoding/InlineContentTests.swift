import Foundation
import Testing
@testable import DocsySchema

@Suite("InlineContent", .tags(.models))
struct InlineContentTests {
    typealias Case = TestCase<InlineContent>
    let decoder = JSONDecoder()

    @Test
    func text() async throws {
        let testCase = Case.text
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test
    func emphasis() async throws {
        let testCase = Case.emphasis
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test
    func strong() async throws {
        let testCase = Case.strong
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test
    func strikethrough() async throws {
        let testCase = Case.strikethrough
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test
    func combinedTextStyles() async throws {
        let testCase = Case.combinedTextStyles
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test
    func superscript() async throws {
        let testCase = Case.superscript
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test
    func `subscript`() async throws {
        let testCase = Case.`subscript`
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test
    func inlineCode() async throws {
        let testCase = Case.codeVoice
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test
    func newTerm() async throws {
        let testCase = Case.newTerm
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test
    func inlineHead() async throws {
        let testCase = Case.inlineHead
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test(arguments: [
        #"https://www.example.com"#,
        #"https:\/\/www.example.com"#,
        #"doc:\/\/swift-docc.SwiftDocC\/documentation\/SwiftDocC\/FeatureFlags"#
    ])
    func reference(identifier: String) async throws {
        let testCase = Case.reference(identifier)
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test
    func image() async throws {
        let testCase = Case.image
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }
}

extension Sequence where Element: Hashable {
    func removingDuplicates() -> some Sequence<Element> {
        Array(Set(self))
    }
}


extension TestCase<InlineContent> {
    static let allCases: [TestCase<InlineContent>] = [
        text, emphasis, strong, strikethrough, combinedTextStyles,
        superscript, `subscript`,
        codeVoice, newTerm, inlineHead,
        reference(),
    ]

    // MARK: Text Style
    static let text = TestCase("text") {
        #"{ "type": "text", "text": "This is plain" }"#
    } value: {
        InlineContent.text("This is plain")
    }

    static let emphasis = TestCase("emphasised") {
            #"""
            { 
                "type": "emphasis", 
                "inlineContent": [ {"type": "text", "text": "This is emphasised"} ]
            }
            """#
    } value: {
        InlineContent.emphasis(inlineContent: [.text("This is emphasised")])
    }

    static let strong = TestCase("strong") {
            #"""
            { 
                "type": "strong", 
                "inlineContent": [ {"type": "text", "text": "This is strong"} ]
            }
            """#
    } value: {
        InlineContent.strong(inlineContent: [.text("This is strong")])
    }

    static let strikethrough = TestCase("inline head") {
            """
            {
                "type": "strikethrough",
                "inlineContent": [\(text.json)]
            }
            """
    } value: {
        InlineContent.strikethrough(inlineContent: [text.value])
    }

    static let combinedTextStyles = TestCase("combined test styles") {
            #"""
            {
                "type": "strong",
                "inlineContent": [
                    {
                        "inlineContent": [
                            {
                                "inlineContent": [
                                    {
                                        "type": "text",
                                        "text": "This is strong and emphasised"
                                    }
                                ],
                                "type": "strikethrough"
                            }
                        ],
                        "type": "emphasis"
                    }
                ]
            }
            """#
    } value: {
        InlineContent.strong(inlineContent: [
            .emphasis(inlineContent: [
                .strikethrough(inlineContent: [
                    .text("This is strong and emphasised")
                ])
            ])
        ])
    }

    // MARK: Subscript / Superscript
    static let `subscript` = TestCase("subscript") {
            """
            {
                "type": "subscript",
                "inlineContent": [\(text.json)]
            }
            """
    } value: {
        InlineContent.subscript(inlineContent: [text.value])
    }

    static let superscript = TestCase("superscript") {
            """
            {
                "type": "superscript",
                "inlineContent": [\(text.json)]
            }
            """
    } value: {
        InlineContent.superscript(inlineContent: [text.value])
    }


    static let codeVoice = TestCase("code") {
            #"""
            {
                "type": "codeVoice",
                "code": "this is code"
            }
            """#
    } value: {
        InlineContent.codeVoice(code: "this is code")
    }

    static let newTerm = TestCase("new term") {
            """
            {
                "type": "newTerm",
                "inlineContent": [\(text.json)]
            }
            """
    } value: {
        InlineContent.newTerm(inlineContent: [text.value])
    }

    static let inlineHead = TestCase("inline head") {
            """
            {
                "type": "inlineHead",
                "inlineContent": [\(text.json)]
            }
            """
    } value: {
        InlineContent.inlineHead(inlineContent: [text.value])
    }

    static func reference(_ identifier: String = "https://example.com") -> TestCase {
        TestCase("reference \(identifier)") {
            """
            {
                "type": "reference",
                "isActive": true,
                "identifier": \(identifier)
            }
            """
        } value: {
            InlineContent.reference(
                identifier: .init(identifier.replacingOccurrences(of: #"\/"#, with: "/")),
                isActive: true,
                overridingTitle: nil,
                overridingTitleInlineContent: nil
            )
        }
    }

    static let image = TestCase("image") {
            #"""
            {
                "type": "image",
                "identifier": "https://www.example.com/image.png"
            }
            """#
    } value: {
        InlineContent.image(
            identifier: .init("https://www.example.com/image.png"),
            metadata: nil
        )
    }
}
