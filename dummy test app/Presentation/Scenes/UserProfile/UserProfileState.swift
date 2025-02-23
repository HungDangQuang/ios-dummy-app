import Foundation

enum UserProfileState {
    case idle
    case loading
    case success
    case error(message: String)
}
