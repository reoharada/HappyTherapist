//
//  YoutubeWindowViewController.swift
//  HappyTherapist
//
//  Created by REO HARADA on 2021/03/20.
//

import UIKit

class YoutubeWindowViewController: UIViewController, WKYTPlayerViewDelegate {

    @IBOutlet weak var playerView: WKYTPlayerView!
    var videoId: String = ""
    var playerWindow: UIWindow!

    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.delegate = self
    }
    
    func showWindow() {
        if let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene {
            playerWindow = UIWindow(windowScene: windowScene)
            playerWindow.backgroundColor = .clear
            playerWindow.rootViewController = self
            playerWindow.windowLevel = UIWindow.Level.statusBar + 1
            playerWindow.makeKeyAndVisible()
            startVideo()
        }
    }
    
    func startVideo() {
        playerView.load(withVideoId: videoId, playerVars: ["playsinline": 1, "controls": 0])
    }
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        playerView.playVideo()
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        // 無限ループさせる
        if state == WKYTPlayerState.ended { playerView.playVideo() }
    }

    @IBAction func tapCloseButton(_ sender: Any) {
        playerView.stopVideo()
        playerWindow = nil
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.makeKeyAndVisible()
    }
    
}
