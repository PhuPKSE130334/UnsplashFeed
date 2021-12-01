//
//  UnplashPostTableViewCell.swift
//  UnsplashFeed
//
//  Created by Phu Phan on 01/12/2021.
//

import UIKit
protocol UnplashPostTablViewCellDelegate: AnyObject {
    
    func reaction(id: String, liked: Bool)
    
}

class UnplashPostTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var reactionButton: UIButton!
    
    @IBOutlet weak var likeCounterLabel: UILabel!
    
    @IBOutlet weak var unplashImageView: UIImageView!
    
    weak var delegate: UnplashPostTablViewCellDelegate?
    
    var postID: String = ""
    
    var likedPost: Bool = false
    
    var imageURL: String = ""
    
    var onReuse: () -> Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        onReuse()
        
        unplashImageView.image = nil
        
    }
    
    @IBAction func onReactionButtonTapped(_ sender: Any) {
        
        reactionButton.setTitleColor(.red, for: .normal)
        
        delegate?.reaction(id: postID, liked: likedPost)
        
    }
}
