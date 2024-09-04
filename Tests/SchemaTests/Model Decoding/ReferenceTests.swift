@testable import DocsySchema
import Foundation
import Testing

@Suite("Reference", .tags(.models))
struct ReferenceTests {
    typealias Case = TestCase<Reference>
    let decoder = JSONDecoder()

    @Test func link() async throws {
        let testCase = Case.link
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test func image() async throws {
        let testCase = Case.image
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

    @Test func video() async throws {
        let testCase = Case.video
        let content = try testCase.decode()
        #expect(content == testCase.value)
    }

//    @Test func video() async throws {
//        let testCase = Case.video
//        let content = try testCase.decode()
//        #expect(content == testCase.value)
//    }

//    @Test func video() async throws {
//        let testCase = Case.video
//        let content = try testCase.decode()
//        #expect(content == testCase.value)
//    }
}

extension TestCase where T == Reference {
    static let allCases: [Self] = [
        link,
        image,
        video,
//        file,
//        fileType,
//        xcodeRequiremen,
//        topic,
//        section,
//        download,
    ]

    static let link = TestCase("link") {
        """
        {
            "type": "link",
            "titleInlineContent": [
                \(TestCase<InlineContent>.text)
            ],
            "identifier": "https://www.example.com",
            "title": "links",
            "url": "https://www.example.com"
        }
        """
    } value: {
        Reference.link(
            LinkReference(
                identifier: .init("https://www.example.com"),
                title: "links",
                titleInlineContent: [TestCase<InlineContent>.text.value],
                url: "https://www.example.com"
            )
        )
    }

    static let image = TestCase("image") {
        """
        {
            "identifier": "slothCreator-icon.png",
            "type": "image",
            "alt": "A technology icon representing the SlothCreator framework.",
            "variants": [
                {
                    "url": "/images/slothcreatorbuildingdoccdocumentationinxcode.SlothCreator/slothCreator-icon-light@2x.png",
                    "traits": [
                        "2x",
                        "light"
                    ]
                },
                {
                    "url": "/images/slothcreatorbuildingdoccdocumentationinxcode.SlothCreator/slothCreator-icon-dark@2x.png",
                    "traits": [
                        "2x",
                        "dark"
                    ]
                }
            ]
        }
        """
    } value: {
        let baseURI = URL(string: "/images/slothcreatorbuildingdoccdocumentationinxcode.SlothCreator")!
        let light2x = baseURI.appending(path: "slothCreator-icon-light@2x.png")
        let dark2x = baseURI.appending(path: "slothCreator-icon-dark@2x.png")

        return Reference.image(
            ImageReference(
                identifier: .init("slothCreator-icon.png"),
                altText: "A technology icon representing the SlothCreator framework.",
                asset: .init(
                    variants: [
                        .init(from: ["2x", "light"]): light2x,
                        .init(from: ["2x", "dark"]): dark2x,
                    ],
                    metadata: [
                        light2x: .init(svgID: nil),
                        dark2x: .init(svgID: nil),
                    ]
                )
            )
        )
    }

    static let video = TestCase("video") {
        """
        {
            "identifier": "slothCreator-video.mp4",
            "type": "video",
            "alt": "A video presenting the SlothCreator framework.",
            "variants": [
                {
                    "url": "/videos/slothCreator-video.mp4",
                    "traits": []
                }
            ],
            "poster": "slothCreator-icon.png"
        }
        """
    } value: {
        let url = URL(string: "/videos/slothCreator-video.mp4")!

        return Reference.video(
            VideoReference(
                identifier: .init("slothCreator-video.mp4"),
                altText: "A video presenting the SlothCreator framework.",
                asset: .init(
                    variants: [.init(from: []): url],
                    metadata: [url: .init()]
                ),
                poster: .init("slothCreator-icon.png")
            )
        )
    }
}
