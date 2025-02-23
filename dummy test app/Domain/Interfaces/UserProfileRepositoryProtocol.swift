import Foundation

protocol UserProfileRepositoryProtocol {
    func fetchUserProfiles(
        completion: @escaping (
            Result<[UserProfile], Error>
        ) -> Void
    )
    
    func searchUserProfiles(
        query: String,
        completion: @escaping (
            [UserProfile]
        ) -> Void
    )
    
}
