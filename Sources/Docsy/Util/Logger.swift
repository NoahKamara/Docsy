//
//  Logger.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

import OSLog

extension Logger {
    static func docsy(_ category: String) -> Logger {
        Logger(subsystem: "com.docsy.docsy", category: category)
    }
}
