//
//  YoutubePlayerViewController.swift
//  HappyTherapist
//
//  Created by REO HARADA on 2021/03/20.
//

import UIKit

class YoutubePlayerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, WKYTPlayerViewDelegate {

    @IBOutlet weak var playerView: WKYTPlayerView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var videoId = ""
    var videoTitle = ""
    var thumnailUrl = ""
    var slectedState = HappyState.highTension
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.delegate = self
        playerView.load(withVideoId: videoId, playerVars: ["playsinline": 1])
    }
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        playerView.playVideo()
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        // 無限ループさせる
        if state == WKYTPlayerState.ended { playerView.playVideo() }
    }
    
    @IBAction func tapSaveButton(_ sender: Any) {
        let userDefault = UserDefaults.standard
        userDefault.setValue([videoId, videoTitle, thumnailUrl], forKey: slectedState.key())
        userDefault.synchronize()
        navigationController?.popViewController(animated: true)
    }
    
    /***** UIPickerView ******/
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return HappyState.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return HappyState.allCases[row].string()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        slectedState = HappyState.allCases[row]
    }
    /***** UIPickerView ******/
}
