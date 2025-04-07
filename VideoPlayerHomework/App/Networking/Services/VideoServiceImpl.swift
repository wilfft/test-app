import Foundation
import UIKit

/// Concrete implementation of video-related services
///
/// ## Responsibilities:
/// - Fetching video lists from API
/// - Managing video downloads and local storage
///
/// ## Error Handling:
/// - Converts network errors to domain-specific errors
final class VideoServiceImpl: VideoServiceProtocol {
    private let networkClient: NetworkClientProtocol
    private let fileManager: FileStorageManagerProtocol
    
    /// Creates a video service instance
    /// - Parameters:
    ///   - networkClient: The network client (default: NetworkClientImpl())
    ///   - fileManager: The file storage manager (default: FileStorageManagerImpl())
    init(networkClient: NetworkClientProtocol = NetworkClientImpl(),
         fileManager: FileStorageManagerProtocol = FileStorageManagerImpl()) {
        self.networkClient = networkClient
        self.fileManager = fileManager
    }
    
    /// Fetches the list of available videos
    /// - Returns: Array of VideoResponse objects
    /// - Throws:
    ///   - `NetworkError` variants for network failures
    ///   - `DecodingError` if response parsing fails
    func fetchVideo() async throws -> [VideoResponse] {
        let endpoint = VideoEndpoint.fetchVideos
        return try await networkClient.request(endpoint)
    }
    
    /// Downloads a video file and saves it locally
    /// - Parameters:
    ///   - url: The remote video URL
    ///   - onProgress: Progress handler closure (0.0 to 1.0)
    /// - Returns: Local file URL where video was saved
    /// - Throws:
    ///   - `NetworkError.invalidLocalPath` if local storage is unavailable
    ///   - `NetworkError` variants for download failures
    ///   - `StorageError` if file operations fail
    ///
    /// ## Storage Behavior:
    /// - Automatically removes existing file if present
    /// - Saves to Documents directory using remote filename
    func downloadVideo(from url: URL, onProgress: @escaping (Double) -> Void) async throws -> URL {
        guard let destinationURL = fileManager.getLocalURL(forRemoteURL: url) else {
            throw NetworkError.invalidLocalPath
        }
        
        try? fileManager.removeFile(at: destinationURL)
        
        let (data, _) = try await networkClient.downloadFile(from: url, progressHandler: onProgress)
        
        try fileManager.saveFile(data: data, to: destinationURL)
        
        return destinationURL
    }
}
