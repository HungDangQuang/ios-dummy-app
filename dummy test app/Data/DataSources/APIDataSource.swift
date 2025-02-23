import Foundation

protocol APIDataSourceProtocol {
    func fetchUsers(
        completion: @escaping (
            Result<[UserProfileDTO], Error>
        ) -> Void
    )
    
    func searchUserProfiles(
        query: String,
        completion: @escaping ([UserProfileDTO]) -> Void
    )
    
    func getDetailUserProfile(
        userID: String,
        completion: @escaping (Result<DetailUserProfileDTO, Error>) -> Void
    )
}

final class APIDataSource: APIDataSourceProtocol {
    func getDetailUserProfile(
        userID: String,
        completion: @escaping (Result<DetailUserProfileDTO, Error>) -> Void
    ) {
        let baseURL = URL(string: "https://dummyapi.io/data/v1/user/\(userID)")!
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        
        // Add headers here
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request
            .addValue(
                "62ac06c74dc7f54c671c587b",
                forHTTPHeaderField: "app-id"
            )
        
        URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let responseData = try JSONDecoder().decode(
                    DetailUserProfileDTO.self,
                    from: data
                )
                completion(.success(responseData))
            } catch {
                print(error)
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    private var currentUserProfileList: [UserProfileDTO] = []
    
    func fetchUsers(
        completion: @escaping (Result<[UserProfileDTO], Error>) -> Void
    ) {
        let baseURL = URL(string: "https://dummyapi.io/data/v1/user")!
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        
        // Add headers here
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request
            .addValue(
                "62ac06c74dc7f54c671c587b",
                forHTTPHeaderField: "app-id"
            )
        
        URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let responseData = try JSONDecoder().decode(
                    UserResponseDTO.self,
                    from: data
                )
                self.currentUserProfileList = responseData.data
                completion(.success(responseData.data))
            } catch {
                print(error)
                completion(.failure(error))
            }
        }.resume()
    }
    
    func searchUserProfiles(
        query: String,
        completion: @escaping ([UserProfileDTO]) -> Void
    ) {
        let filteredItems = currentUserProfileList.filter {
            $0.firstName.lowercased().hasPrefix(query.lowercased())
        }
        completion(filteredItems)
    }
    
}
