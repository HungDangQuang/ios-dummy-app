// Presentation/Scenes/UserProfile/UserProfileViewController.swift
import UIKit

final class UserProfileViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchTimer: Timer?
    private var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserProfileCell.self, forCellReuseIdentifier: UserProfileCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        return tableView
    }()
    
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
    
    // MARK: - Properties
    private let viewModel: UserProfileViewModelProtocol
    
    // MARK: - Initialization
    init(viewModel: UserProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupSearchController()
        setupBindings()
        setupSearchObservers()
        viewModel.viewDidLoad()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "User Profiles"
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search users..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupSearchObservers() {
        viewModel.searchedUsers.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
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
    private func handleStateChange(_ state: UserProfileState) {
        switch state {
            case .idle:
                break
            case .loading:
                activityIndicator.startAnimating()
                errorLabel.isHidden = true
                tableView.isHidden = true
            case .success:
                activityIndicator.stopAnimating()
                errorLabel.isHidden = true
                tableView.isHidden = false
                tableView.reloadData()
            case .error(let message):
                activityIndicator.stopAnimating()
                tableView.isHidden = true
                errorLabel.text = message
                errorLabel.isHidden = false
                showErrorAlert(message: message)
        }
    }
    
    // MARK: - Error Handling
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.retryLoading()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? viewModel.numberOfSearchedUsers : viewModel.numberOfUsers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: UserProfileCell.reuseIdentifier,
            for: indexPath
        ) as? UserProfileCell else {
            return UITableViewCell()
        }
        
        let user = isSearching ? viewModel.searchedUser(at: indexPath.row) : viewModel.user(at: indexPath.row)
        cell.configure(with: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("did selected item")
        tableView.deselectRow(at: indexPath, animated: true)
        let user = isSearching ? viewModel.searchedUser(at: indexPath.row) : viewModel.user(at: indexPath.row)
        let detailVC = UserDetailViewController(
            viewModel: DetailUserProfileViewModel(
                user: user,
                getDetailUserProfileUseCase: GetDetailUserProfileUseCase(
                    repository: DetailUserProfileRepository(
                        datasource: APIDataSource()
                    )
                )
            )
        )
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension UserProfileViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(
            withTimeInterval: 0.3,
            repeats: false
        ) { [weak self] _ in
            self?.viewModel.searchUsers(query: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.clearSearch()
    }
}

