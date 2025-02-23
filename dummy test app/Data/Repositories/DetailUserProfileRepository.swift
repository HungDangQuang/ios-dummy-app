import Foundation

final class DetailUserProfileRepository: DetailUserProfileRepositoryProtocol {
    
    private let datasource: APIDataSourceProtocol
    
    init(datasource: APIDataSourceProtocol) {
        self.datasource = datasource
    }
    
    func getDetailUserProfile(
        userID: String,
        completion: @escaping (Result<DetailUserProfile, any Error>) -> Void
    ) {
        datasource.getDetailUserProfile(userID: userID) { result in
            switch result {
                case .success(let detailProfile):
                    completion(.success(detailProfile.toDomain()))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
