//
//  MovieRouter.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Alamofire

enum MovieRouter: APIRouter {
    case getPopularMovies(page: Int)
    case getMovieDetail(id: Int)
    
    var path: String {
        switch self {
        case .getPopularMovies:
            return "/movie/popular"
        case .getMovieDetail(let id):
            return "/movie/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getPopularMovies, .getMovieDetail:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getPopularMovies(let page):
            return ["page": page]
        case .getMovieDetail:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
            // TODO: Add authorization header if needed
        ]
    }
}

