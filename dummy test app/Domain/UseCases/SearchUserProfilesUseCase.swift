final class SearchUserProfilesUseCase {
    private let repository: UserProfileRepositoryProtocol
    
    init(repository: UserProfileRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String, completion: @escaping ([UserProfile]) -> Void) {
        repository.searchUserProfiles(query: query) { result in
            completion(result)
        }
    }
}

