//
//  ContentSection.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

/// A block content element.
public enum BlockContent: Schema {
    /// A paragraph of content.
    case paragraph(Paragraph)
    /// An aside block.
    case aside(Aside)
    /// A block of sample code.
    case codeListing(CodeListing)
    /// A heading with the given level.
    case heading(Heading)

    // MARK: List

    /// A list that contains ordered items.
    case orderedList(OrderedList)
    /// A list that contains unordered items.
    case unorderedList(UnorderedList)
    /// A list of terms.
    case termList(TermList)

    // MARK: Table

    /// A table that contains a list of row data.
    case table(Table)

//    /// A row in a grid-based layout system that describes a collection of columns.
//    case row(Row)
//    /// A collection of content that should be rendered in a tab-based layout.
//    case tabNavigator(TabNavigator)
//    /// A paragraph of small print content that should be rendered in a small font.
//    case small(Small)

//    /// A step in a multi-step tutorial.
//    case step(TutorialStep)
//    /// A REST endpoint example that includes a request and the expected response.
//    case endpointExample(EndpointExample)
//    /// An example that contains a sample code block.
//    case dictionaryExample(DictionaryExample)
//
//
//    /// A collection of authored links that should be rendered in a similar style
//    /// to links in an on-page Topics section.
//    case links(Links)
//
//    /// A video with an optional caption.
//    case video(Video)

    /// An authored thematic break between block elements.
    case thematicBreak
}
