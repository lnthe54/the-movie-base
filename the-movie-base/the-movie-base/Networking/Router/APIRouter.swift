//
//  APIRouter.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Alamofire
import Foundation

/// Protocol cho API Router
/// Mỗi router sẽ implement URLRequestConvertible để định nghĩa endpoint
protocol APIRouter: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
    var encoding: ParameterEncoding { get }
}

extension APIRouter {
    var baseURL: String {
        return "https://api.example.com" // TODO: Replace with actual base URL
    }
    
    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL().appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.headers = headers ?? HTTPHeaders()
        
        return try encoding.encode(request, with: parameters)
    }
}

