
struct UserResponseDTO: Decodable {
    let data: [UserProfileDTO]
    let total: Int
    let page: Int
    let limit: Int
    private enum CodingKeys: String, CodingKey {
        case data, total, page, limit
    }
}
