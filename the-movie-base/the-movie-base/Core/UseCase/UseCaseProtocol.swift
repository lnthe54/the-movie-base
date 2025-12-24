//
//  UseCaseProtocol.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Foundation

/// Protocol cơ bản cho tất cả UseCase
/// UseCase chứa business logic và điều phối giữa Repository và Presenter
protocol UseCaseProtocol {
    associatedtype Input
    associatedtype Output
    
    /// Thực thi UseCase
    /// - Parameter input: Input data cho UseCase
    /// - Returns: Output result
    func execute(input: Input) async throws -> Output
}

/// Base UseCase với generic types
class BaseUseCase<Input, Output>: UseCaseProtocol {
    func execute(input: Input) async throws -> Output {
        fatalError("Subclasses must implement execute(input:)")
    }
}

