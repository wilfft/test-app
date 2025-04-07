import Combine

/// ViewModel responsible for managing the video list state and data flow
///
/// ## Responsibilities:
/// - Fetching and maintaining the list of videos
/// - Managing loading/error states
/// - Providing data to the view layer
///
/// ## State Management:
/// Uses `ViewStateEnum` to represent:
/// - `.idle`: Initial state
/// - `.loading`: Data fetching in progress
/// - `.loaded([VideoResponse])`: Successful data load
/// - `.error(NetworkError)`: Failure state
///
/// ## Thread Safety:
/// - All state mutations are performed on the main thread
/// - `@MainActor` guarantees thread-safe property access
final class VideoListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The current state of the view model
    /// - Note: Marked as `private(set)` to prevent external modification
    @Published private(set) var state: ViewStateEnum<[VideoResponse]> = .idle
    
    // MARK: - Dependencies
    
    /// The video service used for network operations
    private let network: VideoServiceProtocol
    
    // MARK: - Private Properties
    
    /// Storage for Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Creates a VideoListViewModel instance
    /// - Parameter network: The video service to use (default: VideoServiceImpl())
    init(network: VideoServiceProtocol = VideoServiceImpl()) {
        self.network = network
    }
    
    // MARK: - Public Methods
    
    /// Loads videos from the network and updates the view state
    /// - Important: Must be called from the main thread
    /// - Note: Automatically handles error states and type conversion
    ///
    /// ## State Transitions:
    /// 1. Sets state to `.loading` when called
    /// 2. On success: transitions to `.loaded` with video data
    /// 3. On failure: transitions to `.error` with appropriate error
    ///
    /// ## Error Handling:
    /// - Converts network errors to `NetworkError` type
    /// - Falls back to `.invalidURL` for unexpected errors
    @MainActor
    func loadVideos() async {
        state = .loading
        
        do {
            let videos = try await network.fetchVideo()
            state = .loaded(videos)
        } catch let error as NetworkError {
            state = .error(error)
        } catch {
            state = .error(.invalidURL)
        }
    }
}
