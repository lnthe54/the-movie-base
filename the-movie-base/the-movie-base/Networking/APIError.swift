//
//  APIError.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case noContent
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case noAllowed
    case conflict
    case internalServerError
    case unknown(Error)
    case decodingError(Error)
    case networkError(Error)
    case encryptionError(Error)
    case timeout
    case requestTimeout(TimeInterval)
    case responseTimeout(TimeInterval)
    
    var errorDescription: String? {
        switch self {
        case .noContent:
            return "No content available"
        case .badRequest:
            return "Bad request"
        case .unauthorized:
            return "Unauthorized"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not found"
        case .noAllowed:
            return "Method not allowed"
        case .conflict:
            return "Conflict"
        case .internalServerError:
            return "Internal server error"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .encryptionError(let error):
            return "Encryption error: \(error.localizedDescription)"
        case .timeout:
            return "Request timeout. Please check your connection and try again."
        case .requestTimeout(let interval):
            return "Request timeout after \(Int(interval)) seconds. Please try again."
        case .responseTimeout(let interval):
            return "Response timeout after \(Int(interval)) seconds. Please try again."
        }
    }
}

