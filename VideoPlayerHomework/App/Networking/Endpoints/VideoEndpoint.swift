import Foundation

enum VideoEndpoint: EndpointProtocol {
    case fetchVideos
    
    var url: URL {
        switch self {
        case .fetchVideos:
            URL(string: "https://gist.githubusercontent.com/poudyalanil/ca84582cbeb4fc123a13290a586da925/raw/14a27bd0bcd0cd323b35ad79cf3b493dddf6216b/videos.json")!
        }
    }
    
    var method: HTTPMethod { .get }
    var headers: [String: String]? { nil }
    var parameters: [String: Any]? { nil }
}

