import Foundation
import Testing
@testable import DocsySchema


@Suite("BlockContent", .tags(.models))
struct BlockContentTests {
    typealias Case = TestCase<BlockContent>
    let decoder = JSONDecoder()

    @Test func paragraph() async throws {
        let testCase = Case.paragraph
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test(arguments: Case.asideStyleCases)
    func aside(style: BlockContent.AsideStyle) async throws {
        let defaultTitleCase = Case.aside(name: nil, style)
        let defaultTitleContent = try defaultTitleCase.decode()
        #expect(defaultTitleContent == defaultTitleCase.value)

        let customTitleCase = Case.aside(name: "Hello There", style)
        let customTitleContent = try customTitleCase.decode()
        #expect(customTitleContent == customTitleCase.value)
    }

    @Test(arguments: ["swift", nil])
    func codeListing(syntax: String?) async throws {
        let testCase = Case.codeListing(
            syntax: syntax,
            code: [
                "let thing = Thing.get()",
                "thing.do()"
            ],
            metadata: .init()
        )
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test(arguments: [1, 2, 3, 4, 5, 6])
    func heading(level: Int) async throws {
        let testCase = Case.heading(level: level)
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }
}



extension TestCase where T == BlockContent {
    static let allCases: [Self] = [
//        link,
//        image,
//        video,
//        //        file,
//        //        fileType,
//        //        xcodeRequiremen,
//        //        topic,
//        //        section,
//        //        download,
    ]

    static let paragraph = TestCase("paragraph") {
        """
        {
            "type": "paragraph",
            "inlineContent": [
                \(TestCase<InlineContent>.text)
            ]
        }
        """
    } value: {
        BlockContent.paragraph(
            BlockContent.Paragraph(inlineContent:  [
                TestCase<InlineContent>.text.value
            ])
        )
    }

    static let asideStyleCases: [BlockContent.AsideStyle] = BlockContent.AsideStyle.Known.allCases.map({
        .known($0)
    }) + [.unknown("My Custom Case")]


    static func aside(
        name: String? = "My Aside",
        _ style: BlockContent.AsideStyle
    ) -> TestCase {
        TestCase("aside") {
            """
            {
                "type": "aside",
                "style": \(style.rawValue),
                "name": \(name),
                "content": [
                    \(paragraph.json)
                ]
            }
            """
        } value: {
            BlockContent.aside(
                .init(
                    displayName: name,
                    style: style,
                    content: [paragraph.value]
                )
            )
        }
    }


    static func codeListing(syntax: String?, code: [String], metadata: ContentMetadata) -> TestCase {
        TestCase("codeListing") {
        """
        {
            "type": "codeListing",
            "syntax": \(syntax),
            "code": \(code)
        }
        """
        } value: {
            BlockContent.codeListing(
                .init(
                    syntax: syntax,
                    code: code,
                    metadata: .none
                )
            )
        }
    }

    static func heading(
        level: Int = 1
    ) -> TestCase {
        TestCase("heading") {
            """
            {
                "type": "heading",
                "level": \(level),
                "anchor": "my-heading",
                "text": "Heading \(level)",
                "titleInlineContent": [
                    \(TestCase<InlineContent>.text.json)
                ]
            }
            """
        } value: {
            BlockContent.heading(
                .init(
                    level: level,
                    text: "Heading \(level)",
                    anchor:  "my-heading"
                )
            )
        }
    }
}

extension TestCase<BlockContent.ListItem> {
    static func item(isChecked: Bool) -> Self {
        let content = [ TestCase<BlockContent>.paragraph ]

        return TestCase("list-item") {
            """
            {
                "checked": \(isChecked)
                "content": \(content)
            }
            """
        } value: {
            return BlockContent.ListItem(
                content: content.map(\.value),
                checked: isChecked
            )
        }
    }
}



