//
//  MovieRepository.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Foundation

/// Protocol định nghĩa các method cho Movie Repository
protocol MovieRepositoryProtocol: RemoteRepositoryProtocol where Entity == MovieEntity {
    func getPopularMovies(page: Int) async throws -> MovieListResponse
    func getMovieDetail(id: Int) async throws -> MovieEntity
}

/// Implementation của Movie Repository
final class MovieRepository: MovieRepositoryProtocol {
    typealias Entity = MovieEntity
    
    let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func getPopularMovies(page: Int) async throws -> MovieListResponse {
        return try await apiClient.request(MovieRouter.getPopularMovies(page: page))
    }
    
    func getMovieDetail(id: Int) async throws -> MovieEntity {
        return try await apiClient.request(MovieRouter.getMovieDetail(id: id))
    }
}

