//
//  PresenterProtocol.swift
//  the-movie-base
//
//  Created by lnthe on 24/12/25.
//

import Foundation

/// Protocol cơ bản cho tất cả Presenter trong MVP pattern
/// Presenter chứa presentation logic và giao tiếp với View thông qua ViewProtocol
protocol PresenterProtocol: AnyObject {
    associatedtype View: ViewProtocol
    
    var view: View? { get set }
    
    /// Được gọi khi view đã load
    func viewDidLoad()
    
    /// Được gọi khi view sẽ xuất hiện
    func viewWillAppear()
    
    /// Được gọi khi view đã xuất hiện
    func viewDidAppear()
    
    /// Được gọi khi view sẽ biến mất
    func viewWillDisappear()
    
    /// Được gọi khi view đã biến mất
    func viewDidDisappear()
}

/// Base Presenter implementation
class BasePresenter<View: ViewProtocol>: PresenterProtocol {
    weak var view: View?
    
    init(view: View) {
        self.view = view
    }
    
    func viewDidLoad() {
        // Override nếu cần
    }
    
    func viewWillAppear() {
        // Override nếu cần
    }
    
    func viewDidAppear() {
        // Override nếu cần
    }
    
    func viewWillDisappear() {
        // Override nếu cần
    }
    
    func viewDidDisappear() {
        // Override nếu cần
    }
}

