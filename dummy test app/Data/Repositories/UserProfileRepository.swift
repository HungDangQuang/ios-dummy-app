import Foundation

final class UserProfileRepository: UserProfileRepositoryProtocol {
    
    private let datasource: APIDataSourceProtocol
    
    init(datasource: APIDataSourceProtocol) {
        self.datasource = datasource
    }
    
    func fetchUserProfiles(
        completion: @escaping (Result<[UserProfile], any Error>) -> Void
    ) {
        datasource.fetchUsers { result in
            switch result {
                case .success(let userProfileDTOs):
                    completion(.success(userProfileDTOs.map { $0.toDomain() }))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func searchUserProfiles(
        query: String,
        completion: @escaping ([UserProfile]) -> Void
    ) {
        datasource.searchUserProfiles(query: query) { result in
            completion(result.map{ $0.toDomain() })
        }
    }
}

