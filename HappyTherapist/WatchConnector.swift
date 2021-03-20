import Darwin
import UIKit
import WatchConnectivity

class WatchConnector: NSObject, ObservableObject, WCSessionDelegate {
    
    @Published var receivedMessage = "HEARTBEAT : 未受信"
    @Published var receivedRate = 0.0
    @Published var count = 0
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith state= \(activationState.rawValue)")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("didReceiveMessage: \(message)")
        
        DispatchQueue.main.async {
            self.receivedMessage = "HEARTBEAT : \(message["WATCH_MSG"] as! String)"
            self.receivedRate = atof(message["WATCH_MSG"] as! String)
        }
    }
    
    func send() {
        if WCSession.default.isReachable {
            count += 1
            WCSession.default.sendMessage(["PHONE_COUNT" : count], replyHandler: nil) { error in
                print(error)
            }
        }
    }
    
}
