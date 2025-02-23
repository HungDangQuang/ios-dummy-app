import Foundation
struct DetailUserProfileDTO: Codable {
    let id: String
    let title: String
    let firstName: String
    let lastName: String
    let picture: String
    let gender: String
    let email: String
    let dateOfBirth: String
    let phone: String
    let location: LocationDTO
    let registerDate: String
    let updatedDate: String
    
    private enum CodingKeys: String, CodingKey {
        case id, title, firstName, lastName, picture, gender, email, dateOfBirth, phone, location, registerDate, updatedDate
    }
    
    func toDomain() -> DetailUserProfile {
        DetailUserProfile(
            id: id,
            title: title,
            firstName: firstName,
            lastName: lastName,
            picture: picture,
            email: email,
            dateOfBirth: convertToShortDate(dateOfBirth) ?? ""
        )
    }
}

struct LocationDTO: Codable {
    let street: String
    let city: String
    let state: String
    let country: String
    let timezone: String
}

func convertToShortDate(_ dateString: String) -> String? {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    inputFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    guard let date = inputFormatter.date(from: dateString) else {
        return nil
    }
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "yyyy-MM-dd"
    return outputFormatter.string(from: date)
}

