//
//  APIClient.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Alamofire
import CryptoSwift

final class APIClient {
    
    // MARK: - Properties
    
    static let shared = APIClient()
    
    private let sessionManager: Session
    
    /// Default timeout cho request (seconds)
    var defaultRequestTimeout: TimeInterval = 30
    
    /// Default timeout cho response (seconds)
    var defaultResponseTimeout: TimeInterval = 60
    
    // MARK: - Initialization
    
    private init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = defaultRequestTimeout
        configuration.timeoutIntervalForResource = defaultResponseTimeout
        configuration.waitsForConnectivity = true
        let networkLogger = NetworkLogger()
        self.sessionManager = Session(configuration: configuration, eventMonitors: [networkLogger])
    }
    
    /// Khởi tạo với custom timeout
    /// - Parameters:
    ///   - requestTimeout: Timeout cho request (seconds)
    ///   - responseTimeout: Timeout cho response (seconds)
    init(requestTimeout: TimeInterval = 30, responseTimeout: TimeInterval = 60) {
        self.defaultRequestTimeout = requestTimeout
        self.defaultResponseTimeout = responseTimeout
        
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = requestTimeout
        configuration.timeoutIntervalForResource = responseTimeout
        configuration.waitsForConnectivity = true
        let networkLogger = NetworkLogger()
        self.sessionManager = Session(configuration: configuration, eventMonitors: [networkLogger])
    }
    
    // MARK: - Public Methods
    
    /// Thực hiện request thông thường và decode response
    /// - Parameters:
    ///   - urlConvertible: URLRequestConvertible (có thể là URL, URLRequest, hoặc Router)
    ///   - timeout: Custom timeout cho request này (optional, nếu nil sẽ dùng default)
    /// - Returns: Decoded object theo generic type T
    func request<T: Codable>(_ urlConvertible: URLRequestConvertible, timeout: TimeInterval? = nil) async throws -> T {
        // Tạo session với custom timeout nếu cần
        let session = timeout != nil ? createSessionWithTimeout(timeout!) : sessionManager
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(urlConvertible)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        let apiError = self.mapAPIError(statusCode: response.response?.statusCode, error: error)
                        continuation.resume(throwing: apiError)
                    }
                }
        }
    }
    
    /// Thực hiện request với response được mã hóa và cần giải mã
    /// - Parameters:
    ///   - urlConvertible: URLRequestConvertible
    ///   - timeout: Custom timeout cho request này (optional, nếu nil sẽ dùng default)
    /// - Returns: Decoded object sau khi giải mã
    func requestEncrypt<T: Codable>(_ urlConvertible: URLRequestConvertible, timeout: TimeInterval? = nil) async throws -> T {
        // Tạo session với custom timeout nếu cần
        let session = timeout != nil ? createSessionWithTimeout(timeout!) : sessionManager
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(urlConvertible)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let aes = try AES(
                                key: Array(Constants.Encrypt.SECRET.utf8),
                                blockMode: CBC(iv: Array(Constants.Encrypt.IV.utf8)),
                                padding: .pkcs5
                            )
                            
                            let stringEncoded = String(data: data, encoding: .utf8) ?? ""
                            guard let dataEncoded = Data(base64Encoded: stringEncoded) else {
                                continuation.resume(throwing: APIError.noContent)
                                return
                            }
                            
                            let decryptedData = try aes.decrypt(dataEncoded.bytes)
                            let dataDecoded = Data(decryptedData)
                            let stringDecoded = String(data: dataDecoded, encoding: .utf8) ?? ""
                            
                            let decodedData = try JSONDecoder().decode(T.self, from: Data(stringDecoded.utf8))
                            continuation.resume(returning: decodedData)
                        } catch let error {
                            continuation.resume(throwing: APIError.encryptionError(error))
                        }
                    case .failure(let error):
                        let apiError = self.mapAPIError(statusCode: response.response?.statusCode, error: error)
                        continuation.resume(throwing: apiError)
                    }
                }
        }
    }
    
    /// Thực hiện request với retry mechanism khi timeout
    /// - Parameters:
    ///   - urlConvertible: URLRequestConvertible
    ///   - maxRetries: Số lần retry tối đa (default: 2)
    ///   - timeout: Timeout cho mỗi request (optional)
    /// - Returns: Decoded object theo generic type T
    func requestWithRetry<T: Codable>(
        _ urlConvertible: URLRequestConvertible,
        maxRetries: Int = 2,
        timeout: TimeInterval? = nil
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 0...maxRetries {
            do {
                return try await request(urlConvertible, timeout: timeout)
            } catch let error as APIError {
                // Chỉ retry nếu là timeout error
                if case .timeout = error, attempt < maxRetries {
                    lastError = error
                    // Exponential backoff: đợi 1s, 2s, 4s...
                    let delay = pow(2.0, Double(attempt))
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else if case .requestTimeout = error, attempt < maxRetries {
                    lastError = error
                    let delay = pow(2.0, Double(attempt))
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    throw error
                }
            } catch {
                throw error
            }
        }
        
        throw lastError ?? APIError.timeout
    }
    
    // MARK: - Private Methods
    
    /// Tạo Session với custom timeout
    private func createSessionWithTimeout(_ timeout: TimeInterval) -> Session {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 2 // Response timeout = 2x request timeout
        configuration.waitsForConnectivity = true
        let networkLogger = NetworkLogger()
        return Session(configuration: configuration, eventMonitors: [networkLogger])
    }
    
    private func mapAPIError(statusCode: Int?, error: Error) -> APIError {
        // Xử lý timeout errors từ Alamofire
        if let afError = error as? AFError {
            switch afError {
            case .sessionTaskFailed(let sessionError):
                // Kiểm tra nếu là timeout error
                if let urlError = sessionError as? URLError {
                    switch urlError.code {
                    case .timedOut:
                        return APIError.timeout
                    case .networkConnectionLost, .notConnectedToInternet:
                        return APIError.networkError(urlError)
                    default:
                        break
                    }
                }
                
            case .responseValidationFailed(let reason):
                if case .unacceptableStatusCode(let code) = reason {
                    return mapStatusCodeToError(code)
                }
            default:
                break
            }
        }
        
        // Xử lý URLError timeout trực tiếp
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                return APIError.timeout
            case .networkConnectionLost, .notConnectedToInternet:
                return APIError.networkError(urlError)
            default:
                return APIError.networkError(urlError)
            }
        }
        
        // Xử lý APIError timeout đã được throw
        if let apiError = error as? APIError {
            switch apiError {
            case .timeout, .requestTimeout, .responseTimeout:
                return apiError
            default:
                break
            }
        }
        
        if let statusCode = statusCode {
            return mapStatusCodeToError(statusCode)
        }
        
        return APIError.networkError(error)
    }
    
    private func mapStatusCodeToError(_ statusCode: Int) -> APIError {
        switch statusCode {
        case 204:
            return APIError.noContent
        case 400:
            return APIError.badRequest
        case 401:
            return APIError.unauthorized
        case 403:
            return APIError.forbidden
        case 404:
            return APIError.notFound
        case 405:
            return APIError.noAllowed
        case 409:
            return APIError.conflict
        case 500:
            return APIError.internalServerError
        default:
            return APIError.unknown(NSError(domain: "APIError", code: statusCode))
        }
    }
}
