import Foundation

enum NetworkError: Error {
    case decodingFailed(innerError: DecodingError)
    case invalidStatusCode(statusCode: Int)
    case requestFailed(innerError: URLError)
    case otherError(innerError: Error)
    case invalidURL
    case invalidResponse
    case imageDecodingFailed
    case genericError(String)
    case playerError(Error?)
    case invalidLocalPath
    
    var localizedDescription: String {
        switch self {
        case .decodingFailed(let innerError):
            return String(format: NSLocalizedString("decoding_failed", comment: ""), innerError.localizedDescription)
        case .invalidStatusCode(let statusCode):
            return String(format: NSLocalizedString("invalid_status_code", comment: ""), statusCode)
        case .requestFailed(let innerError):
            return String(format: NSLocalizedString("request_failed", comment: ""), innerError.localizedDescription)
        case .otherError(let innerError):
            return String(format: NSLocalizedString("other_error", comment: ""), innerError.localizedDescription)
        case .invalidURL:
            return NSLocalizedString("invalid_url", comment: "")
        case .invalidResponse:
            return NSLocalizedString("invalid_response", comment: "")
        case .imageDecodingFailed:
            return NSLocalizedString("image_decoding_failed", comment: "")
        case .genericError(let message):
            return String(format: NSLocalizedString("generic_error", comment: ""), message)
        case .playerError(let error):
            return error?.localizedDescription ?? NSLocalizedString("player_error_unknown", comment: "")
        case .invalidLocalPath:
            return String(format: NSLocalizedString("invalid_local_path", comment: ""))
        }
    }

}
