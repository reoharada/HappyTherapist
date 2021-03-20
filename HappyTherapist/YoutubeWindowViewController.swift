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
            playerWindow.bounds = CGRect(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2, width: 10, height: 10)
            playerWindow.backgroundColor = .clear
            playerWindow.rootViewController = self
            playerWindow.windowLevel = UIWindow.Level.statusBar + 1
            playerWindow.makeKeyAndVisible()
            self.playerWindow.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
            UIView.animate(withDuration: 1.0) {
                print(UIScreen.main.bounds)
                //self.playerWindow.bounds = UIScreen.main.bounds
                
            } completion: { (animated) in
                print(self.playerWindow.bounds)
                self.startVideo()
            }
        }
    }
    
    func startVideo() {
        playerView.load(withVideoId: videoId, playerVars: ["playsinline": 1])
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
