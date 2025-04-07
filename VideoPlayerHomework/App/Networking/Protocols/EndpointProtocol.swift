import Foundation

protocol EndpointProtocol {
    var url: URL { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}
