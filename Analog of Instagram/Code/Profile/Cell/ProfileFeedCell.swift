//
//  ProfileFeedCell.swift
//  Course2FinalTask
//
//  Created by Павел on 05.07.2020.
//  Copyright © 2020 Pavel Laukhin. All rights reserved.
//

import UIKit

final class ProfileFeedCell: UICollectionViewCell {
        
    var post: Post? {
        didSet {
            guard let post = post else { return }
            postImageView.kf.indicatorType = .activity
            postImageView.kf.setImage(with: URL(string: post.image))
            addSubviews()
            setupLayout()
        }
    }
    
    private var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private func addSubviews() {
        contentView.addSubview(postImageView)
    }
    
    private func setupLayout() {
        postImageView.frame = contentView.bounds
    }
    
}
