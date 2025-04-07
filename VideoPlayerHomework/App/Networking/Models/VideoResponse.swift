import Foundation

struct VideoResponse: Identifiable, Codable {
    let id: String
    let title: String
    let videoUrl: String
    
    var secureVideoUrl: URL? {
        URL(string: videoUrl)
    }
}
