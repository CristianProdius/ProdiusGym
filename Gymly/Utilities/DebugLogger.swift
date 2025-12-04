//
//  DebugLogger.swift
//  ShadowLift
//
//  Created by Claude Code on 04.12.2025.
//

import Foundation

/// Debug logging utility - only prints in DEBUG builds
/// Replaces standard print() calls to ensure logs don't appear in production
///
/// Usage:
///   debugLog("🔧 Setting up view model")
///   debugLog("✅ Operation completed successfully")
///   debugLog("❌ Error:", error.localizedDescription)
///
/// In DEBUG builds: Prints to console
/// In RELEASE builds: Does nothing (compiled out)
func debugLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    let output = items.map { "\($0)" }.joined(separator: separator)
    print(output, terminator: terminator)
    #endif
}

/// Debug print with explicit formatting (for compatibility)
/// Use when you need to pass multiple arguments exactly as with print()
func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    let output = items.map { "\($0)" }.joined(separator: separator)
    print(output, terminator: terminator)
    #endif
}
