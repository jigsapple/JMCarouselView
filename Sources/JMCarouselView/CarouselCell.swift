//
//  CarouselCell.swift
//  PTask_DevIT
//
//  Created by Jignesh Prajapati on 25/04/25.
//

import SDWebImage

class CarouselCell: UICollectionViewCell {
    static let identifier = "CarouselCell"
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let contentContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Content container styling
        contentContainer.backgroundColor = .white
        contentContainer.layer.cornerRadius = 12
        contentContainer.clipsToBounds = true
        contentContainer.layer.shadowColor = UIColor.black.cgColor
        contentContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentContainer.layer.shadowRadius = 8
        contentContainer.layer.shadowOpacity = 0.2
        
        // Image view styling
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // Title label styling
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 2
        
        // Subtitle label styling
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 2
        
        // Add subviews
        contentView.addSubview(contentContainer)
        contentContainer.addSubview(imageView)
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(subtitleLabel)
        
        // Set up constraints
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            imageView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentContainer.heightAnchor, multiplier: 0.7),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -12),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -12),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentContainer.bottomAnchor, constant: -12)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        transform = .identity
    }
    
    func configure(with item: CarouselItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
        if let url = URL(string: item.imageURL) {
            // If using SDWebImage
            if #available(iOS 13.0, *) {
                imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
            } else {
                imageView.sd_setImage(with: url, placeholderImage: nil)
            }
        } else {
            if #available(iOS 13.0, *) {
                imageView.image = UIImage(systemName: "photo")
            }
        }
    }
    
    // Add bounce animation when cell appears
    func applyAppearanceAnimation() {
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        alpha = 0.5
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.transform = .identity
            self.alpha = 1.0
        })
    }
}
