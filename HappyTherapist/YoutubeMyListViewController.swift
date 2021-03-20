//
//  YoutubeMyListViewController.swift
//  HappyTherapist
//
//  Created by REO HARADA on 2021/03/20.
//

import UIKit

class YoutubeMyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var listTableView: UITableView!
    var youtubeWindowViewController: YoutubeWindowViewController!
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listTableView.reloadData()
    }
    
    /***** UITableView ******/
    func numberOfSections(in tableView: UITableView) -> Int {
        return HappyState.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return HappyState.allCases[section].string()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = HappyState.allCases[indexPath.section].key()
        if let savedData = UserDefaults.standard.object(forKey: key) as? [String] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! YouTubeSearchListTableViewCell
            if savedData.count == 3 {
                cell.ytslLabel.text = savedData[1]
                let thumnailUrl = savedData[2]
                if let url = URL(string: thumnailUrl) {
                    if let d = try? Data(contentsOf: url) { cell.ytslImageView.image = UIImage(data: d) }
                }
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noneCell", for: indexPath)
            cell.textLabel?.text = "動画が設定されていません"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let key = HappyState.allCases[indexPath.section].key()
        if let savedData = UserDefaults.standard.object(forKey: key) as? [String] {
            return UIScreen.main.bounds.size.height / 3
        } else {
            return CGFloat(44)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let key = HappyState.allCases[indexPath.section].key()
            userDefault.removeObject(forKey: key)
            userDefault.synchronize()
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = HappyState.allCases[indexPath.section].key()
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
    /***** UITableView ******/
}
