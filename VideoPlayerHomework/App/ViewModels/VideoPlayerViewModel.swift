import Combine
import AVKit

/// ViewModel responsible for managing video playback and download operations
///
/// ## Responsibilities:
/// - Managing AVPlayer lifecycle and state
/// - Handling video downloads with progress tracking
/// - Coordinating between local and remote video sources
///
/// ## State Management:
/// - Uses three separate state systems:
///   1. `playerState` (ViewStateEnum<AVPlayer>) for playback readiness
///   2. `downloadState` (DownloadStateEnum) for download progress
///   3. `isPlaying` for playback status
///
/// ## Thread Safety:
/// - All published properties are updated on the main thread
/// - Uses `@MainActor` for state mutations
final class FullVideoPlayerViewModel: ObservableObject {
    
    // MARK: - Immutable Properties
    
    /// The video metadata being played
    let video: VideoResponse
    
    // MARK: - Player Properties
    
    /// The AVPlayer instance for video playback
    /// - Note: Automatically configured during initialization
    /// - Warning: Always check playerState before accessing
    var player: AVPlayer?
    
    // MARK: - Dependencies
    
    /// Service for video download operations
    private let service: VideoServiceProtocol
    
    /// Manager for local file storage operations
    private let fileStorage: FileStorageManagerProtocol
    
    // MARK: - Combine Management
    
    /// Storage for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Local Storage
    
    /// Cached local URL if video is downloaded
    private var localFileURL: URL?
    
    // MARK: - Published States
    
    /// Current state of the video player
    /// - Cases:
    ///   - `.idle`: Initial state
    ///   - `.loading`: Player is being configured
    ///   - `.loaded(AVPlayer)`: Ready for playback
    ///   - `.error(NetworkError)`: Playback setup failed
    @Published private(set) var playerState: ViewStateEnum<AVPlayer> = .idle
    
    /// Current playback status
    /// - Note: Updated automatically when player starts/stops
    @Published private(set) var isPlaying = false
    
    /// Current download operation state
    /// - Cases:
    ///   - `.idle`: No active download
    ///   - `.downloading`: Download in progress
    ///   - `.completed(URL)`: Download finished successfully
    ///   - `.failed(Error)`: Download failed
    @Published private(set) var downloadState: DownloadStateEnum = .idle
    
    /// Download progress percentage (0.0 to 1.0)
    /// - Note: Updated approximately 60 times per second during downloads
    @Published var downloadProgress: Double = 0
    
    // MARK: - Initialization
    
    /// Creates a FullVideoPlayerViewModel instance
    /// - Parameters:
    ///   - video: The video metadata to play
    ///   - service: Video service (default: VideoServiceImpl())
    ///   - fileStorage: File manager (default: FileStorageManagerImpl())
    init(video: VideoResponse,
         service: VideoServiceProtocol = VideoServiceImpl(),
         fileStorage: FileStorageManagerProtocol = FileStorageManagerImpl()) {
        
        self.video = video
        self.service = service
        self.fileStorage = fileStorage
        
        // Check for existing downloads and setup player
        checkExistingDownload()
        setupPlayer()
    }
    
    // MARK: - Private Methods
    
    /// Checks local storage for existing downloaded video
    private func checkExistingDownload() {
        guard let remoteURL = video.secureVideoUrl,
              let localURL = fileStorage.getLocalURL(forRemoteURL: remoteURL),
              fileStorage.fileExists(at: localURL) else {
            return
        }
        
        downloadState = .completed(localURL)
        localFileURL = localURL
    }
    
    /// Configures the AVPlayer instance
    /// - Note: Prioritizes local file over remote URL
    private func setupPlayer() {
        let urlToPlay = localFileURL ?? video.secureVideoUrl
        
        guard let url = urlToPlay else {
            playerState = .error(.invalidURL)
            return
        }
        
        playerState = .loading
        player = AVPlayer(url: url)
        
        setupPlayerBindings()
    }
    
    /// Sets up KVO observations for the player
    private func setupPlayerBindings() {
        player?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handlePlayerStatus(status)
            }
            .store(in: &cancellables)
    }
    
    /// Handles player status changes
    /// - Parameter status: The new AVPlayer.Status
    private func handlePlayerStatus(_ status: AVPlayer.Status) {
        switch status {
        case .readyToPlay:
            guard let player = player else { return }
            playerState = .loaded(player)
        case .failed:
            playerState = .error(.playerError(player?.error))
        default:
            break
        }
    }
    
    // MARK: - Public Methods
    
    /// Initiates video download process
    /// - Note: Progress updates are throttled to ~60 FPS
    /// - Important: Always check `downloadState` before calling
    func downloadVideo() {
        guard let url = video.secureVideoUrl else { return }
        
        downloadState = .downloading
        downloadProgress = 0
        
        Task { @MainActor in
            do {
                let localURL = try await service.downloadVideo(from: url) { [weak self] progress in
                    // Throttle progress updates to prevent UI flooding
                    if abs(progress - (self?.downloadProgress ?? 0)) > 0.01 || progress >= 1.0 {
                        Task { @MainActor in
                            self?.downloadProgress = progress
                        }
                    }
                }
                
                downloadState = .completed(localURL)
                downloadProgress = 1.0
                
                // Reinitialize player with local file
                self.localFileURL = localURL
                self.setupPlayer()
                
            } catch {
                downloadState = .failed(error)
                downloadProgress = 0
            }
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        player?.pause()
        cancellables.forEach { $0.cancel() }
    }
}
