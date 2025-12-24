//
//  RepositoryProtocol.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Foundation

/// Protocol cơ bản cho tất cả Repository
/// Repository chịu trách nhiệm quản lý data source (API, Local DB, Cache, etc.)
protocol RepositoryProtocol {
    associatedtype Entity
}

/// Protocol cho Remote Repository (API)
protocol RemoteRepositoryProtocol: RepositoryProtocol {
    var apiClient: APIClient { get }
}

/// Protocol cho Local Repository (CoreData, Realm, UserDefaults, etc.)
protocol LocalRepositoryProtocol: RepositoryProtocol {
    // Có thể thêm các method chung cho local repository ở đây
}

