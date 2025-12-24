//
//  MovieEntity.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Foundation

// MARK: - Movie Entity (Domain Model)
struct MovieEntity: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
}

// MARK: - Movie List Response
struct MovieListResponse: Codable {
    let page: Int
    let results: [MovieEntity]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

