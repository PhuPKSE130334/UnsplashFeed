//
//  ClientAPI.swift
//  UnsplashFeed
//
//  Created by Phu Phan on 01/12/2021.
//

import Foundation

class ClientAPI  {
    
    static let shared: ClientAPI = ClientAPI()
    
    let apiKey = "NvYilke_sToJYPJgBLf3FIcNJlAL6IA3r0DV6eySiRY"
    
    let oAuthKey = "d9ksHYIijePI0aj3UNbHlrqaOE2R1k__fC-LmZRVRmY"
    
    let baseUrl = "https://api.unsplash.com/photos"
    
    func getUnplashPhotoListURL(page: Int) -> String {
        
        return "\(baseUrl)?page=\(page)&per_page=20&client_id=\(apiKey)"
        //"https://api.unsplash.com/photos?page=1&per_page=20&client_id=NvYilke_sToJYPJgBLf3FIcNJlAL6IA3r0DV6eySiRY"
    }
    
    func likeUnlikePostQuery(id: String) -> String {
        
        return "/\(id)/like"
        
    }
    
}
