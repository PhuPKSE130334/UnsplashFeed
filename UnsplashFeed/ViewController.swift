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
    
    var currentPage = 1
    
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
        
        addLoadingSpinner()
        
        getUnplashPosts()
        
    }
    
    func addLoadingSpinner() {
        
        spinner.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        spinner.layer.cornerRadius = 10.0
        
        spinner.clipsToBounds = true
        
        spinner.hidesWhenStopped = true
        
        spinner.style = .medium;
        
        spinner.center = view.center
        
        view.addSubview(spinner)
        
    }
    
    func startLoading() {
        
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
                
                let posts = try decoder.decode([UnplashPostModel].self, from: data)
                
                strongSelf.posts.append(contentsOf: posts)
                
                DispatchQueue.main.async {
                    
                    strongSelf.tableView.reloadData()
                    
                }
                
            } catch {
                
                print("Error when parsing Json")
                
            }
            
        }).resume()
    }
    
    
    func reactAPost(id: String, liked: Bool, completionHandler: @escaping (_ newPost: UnplashPostModel) -> Void) {
        
        if let urlComponents = URLComponents(string: ClientAPI.shared.baseUrl + ClientAPI.shared.likeUnlikePostQuery(id: id)) {
            
            guard let url = urlComponents.url else {return}
            
            var request =  URLRequest(url: url)
            
            request.httpMethod = liked ? "DELETE" : "POST"
            
            request.setValue("Bearer \(ClientAPI.shared.oAuthKey)", forHTTPHeaderField: "Authorization")
            
            let config = URLSessionConfiguration.default
            
            let session = URLSession(configuration: config)
            
            session.dataTask(with: request) { [weak self] data, respone, error in
                
                guard self != nil else { return }
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    
                    return
                }
                
                guard let data = data else {return}
                
                let decoder = JSONDecoder()
                
                do {
                    
                    let model = try decoder.decode(UnplashPhotoModel.self, from: data)
                    
                    completionHandler(model.photo)
                    
                } catch {
                    
                    print("Error when parsing Json")
                    
                }
                
                
                
            }.resume()
            
        }
    }
    
    
}

extension ViewController: UnplashPostTablViewCellDelegate {
    
    func reaction(id: String, liked: Bool) {
        
        startLoading()
        
        reactAPost(id: id, liked: liked) { [weak self] newPost in
            
            guard let strongSelf = self else { return }
            
            guard let currentIndex = strongSelf.posts.firstIndex(where: {$0.id == newPost.id}) else { return }
            
            strongSelf.posts[currentIndex] = newPost
            
            DispatchQueue.main.async {
                
                strongSelf.tableView.reloadData()
                
                strongSelf.stopLoading()
                
            }
            
        }
        
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
        
        cell.likedPost = post.likedByUser
        
        cell.reactionButton.titleLabel?.text = post.likedByUser ? "Unlike" : "Like"
        
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let currentOffset = scrollView.contentOffset.y
        
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10.0 {
            
            currentPage += 1
            
            
            
            getUnplashPosts()
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                
                
            }
            
        }
    }
    
}
