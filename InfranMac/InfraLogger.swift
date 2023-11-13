//
//  InfraLogger.swift
//  InfranMac
//
//  Created by Marek Żebrowski on 11/11/2023.
//

import Foundation

import OSLog

extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier!
/// All logs related to tracking and analytics.
    static let events = Logger(subsystem: subsystem, category: "events")
}
