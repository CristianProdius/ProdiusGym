//
//  ImportError.swift
//  ShadowLift
//
//  Created by Claude Code on 04.12.2025.
//

import Foundation

/// Errors that can occur during split file import
enum ImportError: LocalizedError {
    case fileNotFound
    case invalidFormat
    case corruptData(String)
    case accessDenied
    case invalidFileExtension
    case missingRequiredData(String)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "The selected file could not be found. It may have been moved or deleted."

        case .invalidFormat:
            return "This file is not a valid workout split. Please select a .gymlysplit file."

        case .corruptData(let details):
            return "The file appears to be corrupted or incomplete: \(details)"

        case .accessDenied:
            return "Unable to access the file. Please try selecting it again."

        case .invalidFileExtension:
            return "Invalid file type. Please select a file with the .gymlysplit extension."

        case .missingRequiredData(let field):
            return "The split file is missing required information: \(field)"

        case .decodingFailed(let reason):
            return "Failed to read the split file: \(reason)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "Try receiving the file again or saving it to a different location."

        case .invalidFormat, .invalidFileExtension:
            return "Make sure you're importing a workout split file exported from Gymly."

        case .corruptData, .decodingFailed:
            return "The file may have been damaged during transfer. Try exporting it again from the source device."

        case .accessDenied:
            return "Grant file access when prompted, or try selecting the file from a different location."

        case .missingRequiredData:
            return "This file may be from an older version of Gymly. Try exporting a fresh copy."
        }
    }
}
