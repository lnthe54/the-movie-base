//
//  MovieUseCase.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Foundation

// MARK: - Get Popular Movies UseCase

struct GetPopularMoviesInput {
    let page: Int
}

struct GetPopularMoviesOutput {
    let movies: [MovieEntity]
    let totalPages: Int
    let currentPage: Int
}

final class GetPopularMoviesUseCase: BaseUseCase<GetPopularMoviesInput, GetPopularMoviesOutput> {
    private let repository: MovieRepositoryProtocol
    
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    override func execute(input: GetPopularMoviesInput) async throws -> GetPopularMoviesOutput {
        let response = try await repository.getPopularMovies(page: input.page)
        return GetPopularMoviesOutput(
            movies: response.results,
            totalPages: response.totalPages,
            currentPage: response.page
        )
    }
}

// MARK: - Get Movie Detail UseCase

struct GetMovieDetailInput {
    let id: Int
}

struct GetMovieDetailOutput {
    let movie: MovieEntity
}

final class GetMovieDetailUseCase: BaseUseCase<GetMovieDetailInput, GetMovieDetailOutput> {
    private let repository: MovieRepositoryProtocol
    
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    override func execute(input: GetMovieDetailInput) async throws -> GetMovieDetailOutput {
        let movie = try await repository.getMovieDetail(id: input.id)
        return GetMovieDetailOutput(movie: movie)
    }
}

