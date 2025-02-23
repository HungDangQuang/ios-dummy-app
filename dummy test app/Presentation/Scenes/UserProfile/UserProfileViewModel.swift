import Foundation

protocol UserProfileViewModelProtocol {
    var state: Observable<UserProfileState> { get }
    var numberOfUsers: Int { get }
    var numberOfSearchedUsers: Int { get }
    func viewDidLoad()
    func retryLoading()
    func user(at index: Int) -> UserProfile
    func searchedUser(at index: Int) -> UserProfile
    var searchedUsers: Observable<[UserProfile]> { get }
    func searchUsers(query: String)
    func clearSearch()
}


final class UserProfileViewModel: UserProfileViewModelProtocol {
    let searchedUsers = Observable<[UserProfile]>([])
    
    let state: Observable<UserProfileState> = Observable(.idle)
    
    func viewDidLoad() {
        fetchUsers()
    }
    
    func retryLoading() {
        fetchUsers()
    }
    
    private let fetchUserProfilesUseCase: FetchUserProfilesUseCase
    private let searchUserProfileUseCase: SearchUserProfilesUseCase
    private var userProfiles: [UserProfile] = []
    
    init(
        fetchUserProfilesUseCase: FetchUserProfilesUseCase,
        searchUserProfileUsecCase: SearchUserProfilesUseCase) {
            self.fetchUserProfilesUseCase = fetchUserProfilesUseCase
            self.searchUserProfileUseCase = searchUserProfileUsecCase
        }
    
    
    var numberOfUsers: Int {
        return userProfiles.count
    }
    
    var numberOfSearchedUsers: Int {
        return searchedUsers.value.count
    }
    
    func user(at index: Int) -> UserProfile {
        guard index >= 0 && index < userProfiles.count else {
            fatalError("Index out of range")
        }
        return userProfiles[index]
    }
    
    func searchedUser(at index: Int) -> UserProfile {
        guard index >= 0 && index < searchedUsers.value.count else {
            fatalError("Index out of range")
        }
        return searchedUsers.value[index]
    }
    
    func fetchUsers() {
        state.value = .loading
        fetchUserProfilesUseCase.execute { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let userProfiles):
                        self?.userProfiles = userProfiles
                        self?.state.value = .success
                    case .failure(let error):
                        let errorMessage: String
                        
                        switch error {
                            case let apiError as APIError:
                                errorMessage = apiError.localizedDescription
                            case let decodingError as DecodingError:
                                print(error.localizedDescription)
                                errorMessage = "Data format error: \(decodingError.localizedDescription)"
                            default:
                                errorMessage = "Failed to load users. Please try again later."
                        }
                        
                        self?.state.value = .error(message: errorMessage)
                }
            }
        }
    }
    
    func searchUsers(query: String) {
        searchUserProfileUseCase.execute(query: query) { result in
            self.searchedUsers.value = result
        }
    }
    
    func clearSearch() {
        searchedUsers.value = []
    }
}
