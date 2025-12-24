//
//  TimeoutExample.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//
//  File này chứa các ví dụ về cách sử dụng timeout trong APIClient

import Foundation

// MARK: - Ví dụ sử dụng Timeout

class TimeoutExamples {
    
    // MARK: - Example 1: Sử dụng timeout mặc định
    
    func example1_DefaultTimeout() async {
        let apiClient = APIClient.shared
        
        do {
            // Sử dụng timeout mặc định (30 giây)
            // let response: MovieListResponse = try await apiClient.request(MovieRouter.getPopularMovies(page: 1))
            print("Request thành công với timeout mặc định")
        } catch let error as APIError {
            handleTimeoutError(error)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Example 2: Sử dụng custom timeout
    
    func example2_CustomTimeout() async {
        let apiClient = APIClient.shared
        
        do {
            // Sử dụng custom timeout 60 giây cho request này
            // let response: MovieListResponse = try await apiClient.request(
            //     MovieRouter.getPopularMovies(page: 1),
            //     timeout: 60
            // )
            print("Request thành công với custom timeout")
        } catch let error as APIError {
            handleTimeoutError(error)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Example 3: Sử dụng retry mechanism
    
    func example3_RetryOnTimeout() async {
        let apiClient = APIClient.shared
        
        do {
            // Retry tối đa 2 lần khi gặp timeout
            // let response: MovieListResponse = try await apiClient.requestWithRetry(
            //     MovieRouter.getPopularMovies(page: 1),
            //     maxRetries: 2,
            //     timeout: 30
            // )
            print("Request thành công sau retry")
        } catch let error as APIError {
            handleTimeoutError(error)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Example 4: Tạo APIClient với custom timeout
    
    func example4_CustomAPIClient() async {
        // Tạo APIClient với timeout tùy chỉnh
        let apiClient = APIClient(requestTimeout: 60, responseTimeout: 120)
        
        do {
            // Tất cả requests từ apiClient này sẽ dùng timeout 60s
            // let response: MovieListResponse = try await apiClient.request(MovieRouter.getPopularMovies(page: 1))
            print("Request thành công với custom APIClient")
        } catch let error as APIError {
            handleTimeoutError(error)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Example 5: Xử lý timeout trong Repository
    
    func example5_RepositoryWithTimeout() {
        // Repository có thể sử dụng timeout cho các request cụ thể
        /*
        final class MovieRepository: MovieRepositoryProtocol {
            let apiClient: APIClient
            
            func getPopularMovies(page: Int) async throws -> MovieListResponse {
                // Request này cần timeout dài hơn
                return try await apiClient.request(
                    MovieRouter.getPopularMovies(page: page),
                    timeout: 60
                )
            }
            
            func getMovieDetail(id: Int) async throws -> MovieEntity {
                // Request này sử dụng retry mechanism
                return try await apiClient.requestWithRetry(
                    MovieRouter.getMovieDetail(id: id),
                    maxRetries: 3,
                    timeout: 30
                )
            }
        }
        */
    }
    
    // MARK: - Helper Methods
    
    private func handleTimeoutError(_ error: APIError) {
        switch error {
        case .timeout:
            print("⚠️ Request timeout. Please check your connection and try again.")
        case .requestTimeout(let interval):
            print("⚠️ Request timeout after \(Int(interval)) seconds.")
        case .responseTimeout(let interval):
            print("⚠️ Response timeout after \(Int(interval)) seconds.")
        default:
            print("⚠️ Error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Ví dụ sử dụng trong Presenter

extension TimeoutExamples {
    
    func example6_PresenterWithTimeoutHandling() {
        /*
        func loadMovies() {
            Task { @MainActor in
                view?.showLoading()
                do {
                    let input = GetPopularMoviesInput(page: 1)
                    let output = try await getPopularMoviesUseCase.execute(input: input)
                    view?.displayMovies(output.movies)
                } catch let error as APIError {
                    switch error {
                    case .timeout, .requestTimeout, .responseTimeout:
                        // Hiển thị message thân thiện cho user
                        view?.showError(message: "Request timeout. Please check your connection and try again.")
                    case .networkError:
                        view?.showError(message: "Network error. Please check your internet connection.")
                    default:
                        view?.showError(message: error.localizedDescription)
                    }
                } catch {
                    view?.showError(message: error.localizedDescription)
                }
                view?.hideLoading()
            }
        }
        */
    }
}

