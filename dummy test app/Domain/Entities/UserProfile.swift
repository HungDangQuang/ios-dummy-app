import Foundation
import UIKit

struct UserProfile {
    let id: String
    let firstName: String
    let lastName: String
    let title: String
    let pictureURL: String?
    
    init(id: String, title: String, firstName: String, lastName: String, picture: String) {
        self.id = id
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.pictureURL = picture
    }
}
