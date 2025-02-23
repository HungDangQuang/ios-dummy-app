import Foundation

struct UserProfileDTO: Decodable {
    let id: String
    let title: String
    let firstName: String
    let lastName: String
    let picture: String
    
    // If needed for different key mappings
    private enum CodingKeys: String, CodingKey {
        case id, title, firstName, lastName, picture
    }
    
    func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            title: title,
            firstName: firstName,
            lastName: lastName,
            picture: picture
        )
    }
}

