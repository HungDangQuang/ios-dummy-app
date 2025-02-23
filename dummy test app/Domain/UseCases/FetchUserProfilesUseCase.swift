final class FetchUserProfilesUseCase {
    private let repository: UserProfileRepositoryProtocol
    
    init(repository: UserProfileRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(completion: @escaping (Result<[UserProfile], Error>) -> Void) {
        repository.fetchUserProfiles(completion: completion)
    }
}
