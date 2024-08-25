//
//
//import Foundation
//import SwiftUI
//
//struct TestView: View {
//    @Environment(DocumentationContext.self)
//    var ws
//
//    var body: some View {
//        ForEach(ws.bundleIdentifiers, id:\.self) { identifier in
//            Text(identifier)
//        }
//    }
//}
//
//struct ExampleWorkspace: PreviewModifier {
//    static let rootURL = URL(filePath: "/Users/noahkamara/Developer/DocSee/docc.doccarchive")
//
//
//    static func makeSharedContext() async throws -> DocumentationWorkspace {
//        let workspace = DocumentationWorkspace()
//
//        let provider = try LocalFileSystemDataProvider(rootURL: ExampleWorkspace.rootURL)
//        try await workspace.registerProvider(provider)
//
//        return workspace
//    }
//
//    func body(content: Content, context: DocumentationWorkspace) -> some View {
//        content
//            .environment(\.documentationWorkspace, context)
//    }
//}
//
//extension PreviewTrait where T == Preview.ViewTraits {
//    public static var workspace: PreviewTrait<T> {
//        Self.modifier(ExampleWorkspace())
//    }
//}
//
//#Preview(traits: .workspace){
//    TestView()
//}
