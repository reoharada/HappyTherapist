//
//  YoutubeListViewController.swift
//  HappyTherapist
//
//  Created by REO HARADA on 2021/03/20.
//

import UIKit

class YoutubeListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var listTableView: UITableView!
    
    let refreshAccessTokenURL = "https://accounts.google.com/o/oauth2/token"
    let refreshToken = "1//0eATxFlGlSh6xCgYIARAAGA4SNwF-L9IrI7YXQQCaIbVzcusi71kt7b3qjunLUj52T2YZP6isQp4-35FAu3f6RJ_x3SfhYarc0sw"
    var accessToken = ""
    let googleAPIClientId = "1012501657650-94joaqg84trm7hj18bcfludrg54h1tr1.apps.googleusercontent.com"
    let googleAPIClientSecret = "PZwK9yYvDKk5-Dsb_Qvkliez"
    let refreshTokenGrantType = "refresh_token"
    
    let youTubeSearchListURL = "https://www.googleapis.com/youtube/v3/search"
    let ytsPart = "snippet"
    let ytsRegionCode = "jp"
    let ytsMaxResults = "50"
    let ytsOrder = "viewCount"
    var ytsItems = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapSearchButton(_ sender: Any) {
        getAccessToken()
        queryTextField.endEditing(true)
    }
    
    /***** YouTubeAPI関連 ******/
    private func getAccessToken() {
        guard let url = URL(string: refreshAccessTokenURL) else { return }
        let queryItems = [
            "client_id": googleAPIClientId,
            "client_secret": googleAPIClientSecret,
            "refresh_token": refreshToken,
            "grant_type": refreshTokenGrantType
        ]
        guard let queryJson = try? JSONSerialization.data(withJSONObject: queryItems, options: .fragmentsAllowed) else { return }
        var request = URLRequest(url: url)
        request.httpBody = queryJson
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            guard let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else { return }
            guard let accessToken = object["access_token"] as? String else { return }
            self.accessToken = accessToken
            DispatchQueue.main.async {
                self.searchMovie()
            }
        }
        task.resume()
    }
    
    private func searchMovie() {
        guard let query = self.queryTextField.text else { return }
        guard var urlComponets = URLComponents(string: youTubeSearchListURL) else { return }
        let queryItems = [
            URLQueryItem(name: "part", value: ytsPart),
            URLQueryItem(name: "regionCode", value: ytsRegionCode),
            URLQueryItem(name: "maxResults", value: ytsMaxResults),
            URLQueryItem(name: "order", value: ytsOrder),
            URLQueryItem(name: "q", value: query),
        ]
        urlComponets.queryItems = queryItems
        guard let url = urlComponets.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            guard let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else { return }
            guard let items = object["items"] as? [[String:Any]] else { return }
            self.ytsItems = items
            DispatchQueue.main.async {
                self.listTableView.reloadData()
            }
        }
        task.resume()
    }
    /***** YouTubeAPI関連 ******/
    
    /***** UITableView関連 ******/
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ytsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! YouTubeSearchListTableViewCell
        if let snippet = ytsItems[indexPath.row]["snippet"] as? [String:Any] {
            let titleAndThumbnailUrl = getTitleAndThumbnailUrl(snippet)
            cell.ytslLabel.text = titleAndThumbnailUrl.0
            if let url = URL(string: titleAndThumbnailUrl.1) {
                if let d = try? Data(contentsOf: url) {
                    cell.ytslImageView.image = UIImage(data: d)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height / 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let id = ytsItems[indexPath.row]["id"] as? [String: String] else { return }
        guard let videoId = id["videoId"] else { return }
        guard let snippet = ytsItems[indexPath.row]["snippet"] as? [String:Any] else { return }
        let titleAndThumbnailUrl = getTitleAndThumbnailUrl(snippet)
        let youtubePlayerViewController = storyboard?.instantiateViewController(withIdentifier: "YoutubePlayerViewController") as! YoutubePlayerViewController
        youtubePlayerViewController.videoTitle = titleAndThumbnailUrl.0
        youtubePlayerViewController.thumnailUrl = titleAndThumbnailUrl.1
        youtubePlayerViewController.videoId = videoId
        show(youtubePlayerViewController, sender: nil)
    }
    /***** UITableView関連 ******/
    
    private func getTitleAndThumbnailUrl(_ snippet: [String:Any]) -> (String, String) {
        var title = ""
        var thumbnailUrl = ""
        if let t = snippet["title"] as? String { title = t }
        if let thumbnails = snippet["thumbnails"] as? [String:Any] {
            if let high = thumbnails["high"] as? [String:Any] {
                if let url = high["url"] as? String { thumbnailUrl = url }
            }
        }
        return (title, thumbnailUrl)
    }
}

class YouTubeSearchListTableViewCell: UITableViewCell {
    @IBOutlet weak var ytslLabel: UILabel!
    @IBOutlet weak var ytslImageView: UIImageView!
}
