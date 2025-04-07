import Foundation

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func fetchByteStream(from url: URL) async throws -> (any AsyncSequence<UInt8, Error>, URLResponse)
}
