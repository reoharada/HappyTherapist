import UIKit
import WatchConnectivity

class PhoneConnector: NSObject, ObservableObject, WCSessionDelegate {
    
    @Published var receivedMessage = "PHONE : 未受信"
    
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("didReceiveMessage: \(message)")
        
        DispatchQueue.main.async {
            self.receivedMessage = "PHONE : \(message["PHONE_COUNT"] as! Int)"
        }
    }
    
    func sendMessage(msg: String) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["WATCH_MSG" : msg], replyHandler: nil) { error in
                print(error)
            }
        }
    }
}
