//
//  ImageListTableViewCell.swift
//  IosMachineTest
//
//  Created by Shahrukh on 09/11/24.
//

import UIKit

class ImageListTableViewCell: UITableViewCell {
    
    //OutLet
  @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageHeightConstraint?.isActive = false
        imageHeightConstraint = customImageView.heightAnchor.constraint(equalToConstant: 200)
        imageHeightConstraint.isActive = true
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

      
    }
    
    
    func configure(with image: UIImage) {
        customImageView.image = image
        let aspectRatio = image.size.height / image.size.width
        let width = customImageView.frame.width
        imageHeightConstraint.constant = width * aspectRatio
        self.layoutIfNeeded()
    }
        

    
}
