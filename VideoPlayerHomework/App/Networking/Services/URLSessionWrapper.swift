import Foundation

class URLSessionWrapper: URLSessionProtocol {
   
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await session.data(for: request, delegate: nil)
    }
    
    func fetchByteStream(from url: URL) async throws -> (any AsyncSequence<UInt8, Error>, URLResponse) {
        let (bytes, response) = try await session.bytes(from: url, delegate: nil)
        return (bytes, response)
    }
}
