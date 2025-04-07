import Foundation

/// Concrete implementation of local file system management
///
/// ## Responsibilities:
/// - Managing file storage operations in the app's Documents directory
/// - Providing file existence checks
/// - Handling file save/delete operations
///
/// ## Thread Safety:
/// - All methods are thread-safe (FileManager is thread-safe by default)
/// - Serializes file system operations internally
final class FileStorageManagerImpl: FileStorageManagerProtocol {
    
    // MARK: - Dependencies
    
    /// The FileManager instance used for all operations
    /// - Note: Defaults to FileManager.default
    private let fileManager: FileManager
    
    // MARK: - Initialization
    
    /// Creates a file storage manager instance
    /// - Parameter fileManager: The FileManager to use (default: .default)
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    // MARK: - Public Methods
    
    /// Resolves a local file URL for a given remote URL
    /// - Parameter remoteURL: The source URL to derive local path from
    /// - Returns: Local URL in Documents directory with same lastPathComponent
    /// - Note: Does not check if file exists at the location
    func getLocalURL(forRemoteURL remoteURL: URL) -> URL? {
        guard let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(remoteURL.lastPathComponent)
    }
    
    /// Checks if a file exists at the specified URL
    /// - Parameter url: The file URL to check
    /// - Returns: Boolean indicating file existence
    /// - Important: Only checks path existence, not readability
    func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
    
    /// Saves data to a specified location
    /// - Parameters:
    ///   - data: The Data to be saved
    ///   - destinationURL: The target file URL
    /// - Throws:
    ///   - FileSystemError.permissionDenied if lacking write permissions
    ///   - FileSystemError.insufficientSpace if storage is full
    ///   - FileSystemError.directoryCreationFailed if intermediate folders can't be created
    ///
    /// ## Behavior:
    /// - Automatically creates intermediate directories if needed
    /// - Overwrites existing files at destination
    func saveFile(data: Data, to destinationURL: URL) throws {
        try fileManager.createDirectory(
            at: destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: destinationURL)
    }
    
    /// Deletes a file at the specified URL
    /// - Parameter url: The file URL to delete
    /// - Throws: FileSystemError if deletion fails
    /// - Note: Fails silently if file doesn't exist
    func removeFile(at url: URL) throws {
        if fileExists(at: url) {
            try fileManager.removeItem(at: url)
        }
    }
}
