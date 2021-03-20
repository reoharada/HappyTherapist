//
//  HomeViewController.swift
//  HappyTherapist
//
//  Created by REO HARADA on 2021/03/20.
//

import UIKit

class HomeViewController: UIViewController {
    
    let userDefault = UserDefaults.standard
    var youtubeWindowViewController: YoutubeWindowViewController!
    let lineUrl = "https://happy-line-hackday2021.herokuapp.com/linepush"
    let lineUserId = "U069f373b357c50b53247160bbff8bb27"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func 集中力が高まってるよ(_ sender: Any) {
        showPalyer(HappyState.highTension.key())
        postLineMessage(HappyState.highTension.string())
    }
    
    @IBAction func ハッピーフィナーレくるぅ(_ sender: Any) {
        showPalyer(HappyState.die.key())
        postLineMessage(HappyState.die.string())
    }
    
    @IBAction func 緊急事態発生中(_ sender: Any) {
        showPalyer(HappyState.emergency.key())
        postLineMessage(HappyState.emergency.string())
    }
    
    func showPalyer(_ key: String) {
        if let savedData = userDefault.object(forKey: key) as? [String] {
            if savedData.count == 3 {
                let videoId = savedData[0]
                let vc = storyboard?.instantiateViewController(identifier: "YoutubeWindowViewController") as! YoutubeWindowViewController
                youtubeWindowViewController = vc
                youtubeWindowViewController.videoId = videoId
                youtubeWindowViewController.showWindow()
            }
        }
    }
    
    func postLineMessage(_ message: String) {
        guard var urlComponet = URLComponents(string: lineUrl) else { return }
        let queryItems = [
            URLQueryItem(name: "message", value: message),
            URLQueryItem(name: "userId", value: lineUserId)
        ]
        urlComponet.queryItems = queryItems
        guard let url = urlComponet.url else { return }
        var request = URLRequest(url: url)
        request.httpBody = urlComponet.query?.data(using: .utf8)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(data)
            print(response)
            print(error)
        }
        task.resume()
    }
    
}
