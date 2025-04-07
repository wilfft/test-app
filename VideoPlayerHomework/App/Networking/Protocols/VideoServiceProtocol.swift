import Foundation

protocol VideoServiceProtocol {
    func fetchVideo() async throws -> [VideoResponse]
    func downloadVideo(from url: URL, onProgress: @escaping (Double) -> Void) async throws -> URL
}
