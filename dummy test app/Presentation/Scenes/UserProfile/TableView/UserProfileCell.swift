import Foundation
import UIKit

final class UserProfileCell: UITableViewCell {
    static let reuseIdentifier = String(describing: UserProfileCell.self)
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30 // Circular shape
        imageView.backgroundColor = .lightGray // Placeholder color
        return imageView
    }()
    
    private let firstNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let lastNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(profileImageView)
        cardView.addSubview(firstNameLabel)
        cardView.addSubview(lastNameLabel)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Card View Constraints
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Profile Image Constraints
            profileImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // First Name Label Constraints
            firstNameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            firstNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            firstNameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Last Name Label Constraints
            lastNameLabel.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor, constant: 4),
            lastNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            lastNameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            lastNameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with user: UserProfile) {
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName
        if let url = URL(string: user.pictureURL ?? "") {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        }
    }
}
