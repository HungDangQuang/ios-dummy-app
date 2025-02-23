protocol DetailUserProfileRepositoryProtocol {
    
    func getDetailUserProfile(
        userID: String,
        completion: @escaping (
            Result<DetailUserProfile, Error>
        ) -> Void
    )
}

