//
//  CoordinatorProtocol.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import UIKit

/// Protocol cơ bản cho tất cả Coordinator
/// Coordinator chịu trách nhiệm điều hướng navigation trong app
protocol CoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [CoordinatorProtocol] { get set }
    
    /// Bắt đầu flow của coordinator
    func start()
    
    /// Kết thúc flow và remove coordinator khỏi parent
    func finish()
}

extension CoordinatorProtocol {
    /// Add child coordinator
    func addChildCoordinator(_ coordinator: CoordinatorProtocol) {
        childCoordinators.append(coordinator)
    }
    
    /// Remove child coordinator
    func removeChildCoordinator(_ coordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}

/// Base Coordinator implementation
class BaseCoordinator: CoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [CoordinatorProtocol] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        fatalError("Subclasses must implement start()")
    }
    
    func finish() {
        // Override nếu cần cleanup
    }
}

