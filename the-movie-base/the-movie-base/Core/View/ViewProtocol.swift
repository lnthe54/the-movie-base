//
//  ViewProtocol.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Foundation

/// Protocol cơ bản cho tất cả View trong MVP pattern
/// View chỉ chịu trách nhiệm hiển thị UI và nhận user interactions
protocol ViewProtocol: AnyObject {
    /// Hiển thị loading indicator
    func showLoading()
    
    /// Ẩn loading indicator
    func hideLoading()
    
    /// Hiển thị error message
    /// - Parameter message: Error message
    func showError(message: String)
    
    /// Hiển thị success message
    /// - Parameter message: Success message
    func showSuccess(message: String)
}

