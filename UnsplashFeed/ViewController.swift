//
//  ViewController.swift
//  UnsplashFeed
//
//  Created by Phu Phan on 01/12/2021.
//

import UIKit



class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var posts: [UnplashPostModel] = []
    
    var currentPage = 0
    
    let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height:60))
    
    let imageLoader = ImageLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = CGFloat(100)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "UnplashPostTableViewCell", bundle: nil), forCellReuseIdentifier: "UnplashPostTableViewCell")
        
        getUnplashPosts()
        
    }
    
    func loading() {
        
        spinner.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        spinner.layer.cornerRadius = 10.0
        
        spinner.clipsToBounds = true
        
        spinner.hidesWhenStopped = true
        
        spinner.style = .medium;
        
        spinner.center = view.center
        
        view.addSubview(spinner)
        
        spinner.startAnimating()
               
        view.isUserInteractionEnabled = false
        
    }
    
    func stopLoading() {
        
        spinner.stopAnimating()
        
        view.isUserInteractionEnabled = true
    }
    
    
    func getUnplashPosts() {
        
        guard let  unplashPostUrl = URL(string: ClientAPI.shared.getUnplashPhotoListURL(page: currentPage)) else {return}
        
        URLSession.shared.dataTask(with: unplashPostUrl, completionHandler: { [weak self] (data, respone, error) in
            
            guard let strongSelf = self else { return}
            
            if let error = error {
                
                print(error)
                
                return
                
            }
            
            guard let data = data else {return}
            
            let decoder = JSONDecoder()
            
            do {
                
                strongSelf.posts = try decoder.decode([UnplashPostModel].self, from: data)

                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
                
            } catch {
                
                print("Error when parsing Json")
                
            }
        }).resume()
    }
    
}

extension ViewController: UnplashPostTablViewCellDelegate {
    
    func reaction(id: String, liked: Bool) {
        
        print("ok")
        
        stopLoading()
    }
    
}

extension ViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UnplashPostTableViewCell", for: indexPath) as! UnplashPostTableViewCell
        
        cell.tag = indexPath.row
        
        cell.delegate = self
        
        let post = posts[indexPath.row]
        
        let likes = post.likes
        
        print("\(indexPath.row)")
        
        cell.postID = post.id
        
        cell.likeCounterLabel.text = "\(likes) \(likes <= 1 ? "like" : "likes")"
        
        cell.usernameLabel.text = post.userName
        
        cell.unplashImageView.layer.cornerRadius = 10
        
        cell.unplashImageView.backgroundColor = .gray.withAlphaComponent(0.1)
        
        guard let imageUrl = URL(string: post.imageUrl) else { return cell }
                
        let token = imageLoader.loadImage(imageUrl) { result in
            
            do {
           
                let image = try result.get()
           
                DispatchQueue.main.async {
                
                cell.unplashImageView.image = image
                    
                }
                
            } catch {
          
                print(error)
              
            }
            
        }

        cell.onReuse = {
            
            if let token = token {
              
                self.imageLoader.cancelLoad(token)
              
            }
            
        }
        
        return cell
        
    }
    
}
