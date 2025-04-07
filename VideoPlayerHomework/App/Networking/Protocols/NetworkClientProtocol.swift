import Foundation

protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: EndpointProtocol) async throws -> T
    func downloadFile(from url: URL, progressHandler: @escaping (Double) -> Void) async throws -> (Data, URLResponse)
}
