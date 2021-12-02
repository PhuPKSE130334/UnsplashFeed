//
//  UnplashPostModel.swift
//  UnsplashFeed
//
//  Created by Phu Phan on 01/12/2021.
//

import Foundation

class UnplashPostModel: NSObject, Codable {
    
    var id: String = ""
    
    var likes: Int = 0
    
    var likedByUser: Bool = false
    
    var imageUrl: String  = ""
    
    var userName: String = ""
    
    enum CodingKeys: String, CodingKey {
        
        case id
        
        case likes
        
        case likedByUser = "liked_by_user"
        
        case user
        
        case name
        
        case urls
        
        case rawUrl = "raw"
        
    }
    
    
    func encode(to encoder: Encoder) throws {
        
        
    }
    
    override init() {
        
    }
    
    convenience required init(from decoder: Decoder) throws {
        
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let user = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .user)
        
        let urls = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .urls)
        
        id = try container.decode(String.self, forKey: .id)
        
        likes = try container.decode(Int.self, forKey: .likes)
        
        likedByUser = try container.decode(Bool.self, forKey: .likedByUser)
        
        userName = try user.decode(String.self, forKey: .name)
        
        imageUrl = try urls.decode(String.self, forKey: .rawUrl)
        
        
    }
}
