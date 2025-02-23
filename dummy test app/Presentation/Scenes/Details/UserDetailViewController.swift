import UIKit

class UserDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: DetailUserProfileViewModelProtocol
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // Profile Image
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 60 // Half of 120 width/height
        imageView.backgroundColor = .lightGray // Placeholder color
        return imageView
    }()
    
    // Labels
    private let firstNameLabel = UserDetailViewController.createLabel(title: "FIRST NAME")
    private let lastNameLabel = UserDetailViewController.createLabel(title: "LAST NAME")
    private let emailLabel = UserDetailViewController.createLabel(title: "EMAIL")
    private let dobLabel = UserDetailViewController.createLabel(title: "DATE OF BIRTH")
    
    // Buttons
    private let changeNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("CHANGE NAME", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button
            .addTarget(
                UserDetailViewController.self,
                action: #selector(changeNameTapped),
                for: .touchUpInside
            )
        return button
    }()
    
    private let deleteUserButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("DELETE USER", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 8
        button
            .addTarget(
                UserDetailViewController.self,
                action: #selector(deleteUserTapped),
                for: .touchUpInside
            )
        return button
    }()
    
    // MARK: - Initializer
    init(viewModel: DetailUserProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.viewDidLoad()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        // Add Subviews
        view.addSubview(profileImageView)
        view.addSubview(firstNameLabel)
        view.addSubview(lastNameLabel)
        view.addSubview(emailLabel)
        view.addSubview(dobLabel)
        view.addSubview(changeNameButton)
        view.addSubview(deleteUserButton)
        view.addSubview(activityIndicator)
        
        // Constraints
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastNameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        dobLabel.translatesAutoresizingMaskIntoConstraints = false
        changeNameButton.translatesAutoresizingMaskIntoConstraints = false
        deleteUserButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Labels
            firstNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            firstNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            lastNameLabel.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor, constant: 10),
            lastNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            emailLabel.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor, constant: 10),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            dobLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            dobLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            // Buttons
            changeNameButton.topAnchor.constraint(equalTo: dobLabel.bottomAnchor, constant: 40),
            changeNameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeNameButton.widthAnchor.constraint(equalToConstant: 200),
            changeNameButton.heightAnchor.constraint(equalToConstant: 50),
            
            deleteUserButton.topAnchor.constraint(equalTo: changeNameButton.bottomAnchor, constant: 20),
            deleteUserButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteUserButton.widthAnchor.constraint(equalToConstant: 200),
            deleteUserButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.state.bind { [weak self] state in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handleStateChange(state)
            }
        }
    }
    
    // MARK: - State Handling
    private func handleStateChange(_ state: DetailUserProfileState) {
        switch state {
            case .idle:
                break
            case .loading:
                activityIndicator.startAnimating()
                errorLabel.isHidden = true
            case .success:
                activityIndicator.stopAnimating()
                errorLabel.isHidden = true
                populateUserData()
            case .error(let message):
                activityIndicator.stopAnimating()
                errorLabel.text = message
                errorLabel.isHidden = false
                showErrorAlert(message: message)
        }
    }
    
    private func populateUserData() {
        firstNameLabel.text = "First Name: \(viewModel.detailUserProfile?.firstName ?? "")"
        lastNameLabel.text = "Last Name: \(viewModel.detailUserProfile?.lastName ?? "")"
        emailLabel.text = "Email: \(viewModel.detailUserProfile?.email ?? "")"
        dobLabel.text = "Date of Birth: \(viewModel.detailUserProfile?.dateOfBirth ?? "")"
        
        if let url = URL(string: viewModel.detailUserProfile?.picture ?? "") {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        }
    }
    
    // MARK: - Error Handling
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func changeNameTapped() {
        print("Change Name tapped")
    }
    
    @objc private func deleteUserTapped() {
        print("Delete User tapped")
    }
    
    private static func createLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
}
