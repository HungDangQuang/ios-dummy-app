import Foundation

protocol DetailUserProfileViewModelProtocol {
    var user: UserProfile { get }
    func viewDidLoad()
    var state: Observable<DetailUserProfileState> { get }
    var detailUserProfile: DetailUserProfile? { get }
}

final class DetailUserProfileViewModel: DetailUserProfileViewModelProtocol {
    var detailUserProfile: DetailUserProfile? = nil
    
    let user: UserProfile
    
    let state: Observable<DetailUserProfileState> = Observable(.idle)
    
    private let getDetailUserProfileUseCase: GetDetailUserProfileUseCase
    
    init(user: UserProfile, getDetailUserProfileUseCase: GetDetailUserProfileUseCase) {
        self.user = user
        self.getDetailUserProfileUseCase = getDetailUserProfileUseCase
    }
    
    func viewDidLoad() {
        getDetailUserProfile(userID: user.id)
    }
    
    func getDetailUserProfile(userID: String) {
        state.value = .loading
        getDetailUserProfileUseCase
            .execute(userID: userID) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                        case .success(let detailProfile):
                            self?.detailUserProfile = detailProfile
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
}


