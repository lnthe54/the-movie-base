# Architecture Documentation

## Tổng quan

Dự án sử dụng kiến trúc **MVP + Coordinator** kết hợp với **Repository Pattern** và **UseCase Pattern**.

## Kiến trúc

### 1. MVP Pattern (Model-View-Presenter)

- **Model**: Entity/Domain models (ví dụ: `MovieEntity`)
- **View**: UIViewController implement `ViewProtocol` (ví dụ: `MovieListViewController`)
- **Presenter**: Chứa presentation logic, giao tiếp với UseCase và View (ví dụ: `MovieListPresenter`)

### 2. Coordinator Pattern

- **Coordinator**: Quản lý navigation flow trong app (ví dụ: `MovieCoordinator`)
- Mỗi flow có một Coordinator riêng
- Coordinator tạo và inject dependencies cho ViewController và Presenter

### 3. Repository Pattern

- **Repository**: Quản lý data source (API, Local DB, Cache)
- Mỗi domain có một Repository riêng (ví dụ: `MovieRepository`)
- Repository implement `RepositoryProtocol` hoặc `RemoteRepositoryProtocol`

### 4. UseCase Pattern

- **UseCase**: Chứa business logic cụ thể
- Mỗi UseCase thực hiện một tác vụ cụ thể (ví dụ: `GetPopularMoviesUseCase`)
- UseCase giao tiếp với Repository để lấy data

## Luồng dữ liệu

```
View (ViewController)
    ↓
Presenter
    ↓
UseCase
    ↓
Repository
    ↓
APIClient
    ↓
API
```

## Cấu trúc thư mục

```
the-movie-base/
├── Core/
│   ├── Coordinator/
│   │   └── CoordinatorProtocol.swift
│   ├── Presenter/
│   │   └── PresenterProtocol.swift
│   ├── Repository/
│   │   └── RepositoryProtocol.swift
│   ├── UseCase/
│   │   └── UseCaseProtocol.swift
│   └── View/
│       └── ViewProtocol.swift
├── Networking/
│   ├── APIClient.swift
│   ├── APIError.swift
│   ├── Constants.swift
│   ├── NetworkLogger.swift
│   └── Router/
│       └── APIRouter.swift
└── Examples/
    └── Movie/
        ├── MovieEntity.swift
        ├── MovieRouter.swift
        ├── MovieRepository.swift
        ├── MovieUseCase.swift
        ├── MoviePresenter.swift
        ├── MovieCoordinator.swift
        ├── MovieListViewController.swift
        └── MovieDetailViewController.swift
```

## Cách sử dụng

### 1. Tạo Router

```swift
enum MovieRouter: APIRouter {
    case getPopularMovies(page: Int)
    
    var path: String {
        switch self {
        case .getPopularMovies:
            return "/movie/popular"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        switch self {
        case .getPopularMovies(let page):
            return ["page": page]
        }
    }
}
```

### 2. Tạo Repository

```swift
protocol MovieRepositoryProtocol: RemoteRepositoryProtocol where Entity == MovieEntity {
    func getPopularMovies(page: Int) async throws -> MovieListResponse
}

final class MovieRepository: MovieRepositoryProtocol {
    let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func getPopularMovies(page: Int) async throws -> MovieListResponse {
        return try await apiClient.request(MovieRouter.getPopularMovies(page: page))
    }
}
```

### 3. Tạo UseCase

```swift
struct GetPopularMoviesInput {
    let page: Int
}

struct GetPopularMoviesOutput {
    let movies: [MovieEntity]
}

final class GetPopularMoviesUseCase: BaseUseCase<GetPopularMoviesInput, GetPopularMoviesOutput> {
    private let repository: MovieRepositoryProtocol
    
    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }
    
    override func execute(input: GetPopularMoviesInput) async throws -> GetPopularMoviesOutput {
        let response = try await repository.getPopularMovies(page: input.page)
        return GetPopularMoviesOutput(movies: response.results)
    }
}
```

### 4. Tạo Presenter

```swift
final class MovieListPresenter: BasePresenter<MovieViewProtocol> {
    private let getPopularMoviesUseCase: GetPopularMoviesUseCase
    
    init(view: MovieViewProtocol, getPopularMoviesUseCase: GetPopularMoviesUseCase) {
        self.getPopularMoviesUseCase = getPopularMoviesUseCase
        super.init(view: view)
    }
    
    func loadMovies() {
        Task { @MainActor in
            view?.showLoading()
            do {
                let input = GetPopularMoviesInput(page: 1)
                let output = try await getPopularMoviesUseCase.execute(input: input)
                view?.displayMovies(output.movies)
            } catch {
                view?.showError(message: error.localizedDescription)
            }
            view?.hideLoading()
        }
    }
}
```

### 5. Tạo Coordinator

```swift
final class MovieCoordinator: BaseCoordinator {
    override func start() {
        let repository = MovieRepository()
        let useCase = GetPopularMoviesUseCase(repository: repository)
        let viewController = MovieListViewController()
        let presenter = MovieListPresenter(view: viewController, getPopularMoviesUseCase: useCase)
        viewController.presenter = presenter
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
```

## Xử lý Timeout

### Cấu hình Timeout mặc định

APIClient có cấu hình timeout mặc định:
- **Request Timeout**: 30 giây
- **Response Timeout**: 60 giây

```swift
// Sử dụng timeout mặc định
let response = try await apiClient.request(MovieRouter.getPopularMovies(page: 1))

// Sử dụng custom timeout cho request cụ thể
let response = try await apiClient.request(MovieRouter.getPopularMovies(page: 1), timeout: 60)
```

### Tạo APIClient với custom timeout

```swift
// Tạo APIClient với timeout tùy chỉnh
let apiClient = APIClient(requestTimeout: 60, responseTimeout: 120)
```

### Xử lý Timeout Error

APIClient tự động map các timeout errors thành `APIError`:

```swift
do {
    let response = try await apiClient.request(router)
} catch let error as APIError {
    switch error {
    case .timeout:
        // Xử lý timeout chung
        print("Request timeout")
    case .requestTimeout(let interval):
        // Xử lý request timeout với thông tin thời gian
        print("Request timeout after \(interval) seconds")
    case .responseTimeout(let interval):
        // Xử lý response timeout
        print("Response timeout after \(interval) seconds")
    default:
        // Xử lý các lỗi khác
        break
    }
}
```

### Ví dụ sử dụng trong Repository

```swift
final class MovieRepository: MovieRepositoryProtocol {
    let apiClient: APIClient
    
    func getPopularMovies(page: Int) async throws -> MovieListResponse {
        // Sử dụng timeout dài hơn cho request này
        return try await apiClient.request(
            MovieRouter.getPopularMovies(page: page),
            timeout: 60
        )
    }
    
    func getMovieDetail(id: Int) async throws -> MovieEntity {
        // Sử dụng timeout mặc định
        return try await apiClient.request(
            MovieRouter.getMovieDetail(id: id)
        )
    }
}
```

### Ví dụ xử lý trong Presenter

```swift
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
                view?.showError(message: "Request timeout. Please check your connection and try again.")
            default:
                view?.showError(message: error.localizedDescription)
            }
        } catch {
            view?.showError(message: error.localizedDescription)
        }
        view?.hideLoading()
    }
}
```

## Lưu ý

1. **APIClient**: Sử dụng async/await thay vì RxSwift
2. **Error Handling**: Sử dụng `APIError` enum để xử lý lỗi, bao gồm timeout errors
3. **Dependency Injection**: Dependencies được inject qua constructor
4. **Thread Safety**: Sử dụng `@MainActor` khi cần update UI
5. **Testing**: Có thể dễ dàng mock Repository và UseCase để test

