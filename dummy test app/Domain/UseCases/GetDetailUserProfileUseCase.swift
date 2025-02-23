final class GetDetailUserProfileUseCase {
    
    private let repository: DetailUserProfileRepositoryProtocol
    
    init(repository: DetailUserProfileRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(
        userID: String,
        completion: @escaping (Result<DetailUserProfile, Error>) -> Void
    ) {
        repository.getDetailUserProfile(userID: userID) { result in
            completion(result)
        }
    }
}

