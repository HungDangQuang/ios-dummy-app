import Foundation

enum APIError: LocalizedError {
    case invalidResponse
    case statusCode(Int)
    case invalidData
    case unauthorized
    
    var errorDescription: String? {
        switch self {
            case .invalidResponse:
                return "Invalid server response"
            case .statusCode(let code):
                return "Server returned error code: \(code)"
            case .invalidData:
                return "Received invalid data"
            case .unauthorized:
                return "Authentication required"
        }
    }
}
