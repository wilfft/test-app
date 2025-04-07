
import Foundation

/// Concrete implementation of the network client handling API requests and file downloads.
///
/// ## Responsibilities:
/// - Executing network requests with proper error handling
/// - Downloading files with progress tracking
/// - Decoding JSON responses
///
/// ## Thread Safety:
/// - All methods are thread-safe and can be called from any queue
final class NetworkClientImpl: NetworkClientProtocol {
    private let urlSession: URLSessionProtocol
    private let decoder: JSONDecoder
    
    /// Creates a network client instance
    /// - Parameters:
    ///   - session: The URLSession to use (default: .shared)
    ///   - decoder: The JSONDecoder to use (default: JSONDecoder())
    init(session: URLSessionProtocol = URLSessionWrapper(),
         decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = session
        self.decoder = decoder
    }
    
    /// Downloads a file from the specified URL with progress updates
    /// - Parameters:
    ///   - url: The remote file URL
    ///   - progressHandler: Closure receiving download progress (0.0 to 1.0)
    /// - Returns: A tuple containing the downloaded Data and URLResponse
    /// - Throws:
    ///   - `NetworkError.invalidResponse` if server response is invalid
    ///   - `URLError` if network request fails
    ///
    /// ## Progress Updates:
    /// - Throttled to ~60 FPS (updates every 0.016 seconds)
    /// - Guarantees final progress of 1.0 even if download completes quickly
    func downloadFile(from url: URL, progressHandler: @escaping (Double) -> Void) async throws -> (Data, URLResponse) {
        let (asyncBytes, response) = try await urlSession.fetchByteStream(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        let length = httpResponse.expectedContentLength
        var data = Data()
        data.reserveCapacity(Int(length))
        
        var lastProgressUpdate = Date()
        var lastProgressValue: Double = 0
        
        for try await byte in asyncBytes {
            data.append(byte)
            
            let currentProgress = Double(data.count) / Double(length)
            let now = Date()
            
            if now.timeIntervalSince(lastProgressUpdate) >= 0.016 || currentProgress >= 1.0 {
                progressHandler(currentProgress)
                lastProgressUpdate = now
                lastProgressValue = currentProgress
            }
        }
        
        if lastProgressValue < 1.0 {
            progressHandler(1.0)
        }
        
        return (data, response)
    }
    
    /// Performs a network request and decodes the response
    /// - Parameter endpoint: The endpoint configuration
    /// - Returns: Decoded response of generic type T
    /// - Throws:
    ///   - `NetworkError.invalidResponse` if response is invalid
    ///   - `NetworkError.invalidStatusCode` for non-2xx responses
    ///   - `NetworkError.decodingFailed` if parsing fails
    ///   - `NetworkError.otherError` for unexpected errors
    func request<T: Decodable>(_ endpoint: EndpointProtocol) async throws -> T {
        let request = URLRequest(url: endpoint.url)
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidStatusCode(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decodingFailed(innerError: error)
        } catch {
            throw NetworkError.otherError(innerError: error)
        }
    }
}
