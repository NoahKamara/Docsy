//
//  Resources.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import Testing

public enum Resources {
    private static let bundle = Bundle.module
}

public extension Resources {
    static func doccarchive(named name: String) -> URL {
        bundle.url(forResource: "Resources/\(name)", withExtension: "doccarchive")!
    }

    static var docc: URL {
        print(Bundle.allBundles)
        print(bundle.resourceURL?.path())
        return bundle.url(forResource: "Resources/docc", withExtension: "doccarchive")!
    }

    static var slothCreator: URL {
        bundle.url(forResource: "Resources/SlothCreator", withExtension: "doccarchive")!
    }
}
