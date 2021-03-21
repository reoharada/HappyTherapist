//
//  HomeViewController.swift
//  HappyTherapist
//
//  Created by REO HARADA on 2021/03/20.
//

import UIKit

struct ParseError: Error {}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var debugAreaView: UIView!
    
    let userDefault = UserDefaults.standard
    var youtubeWindowViewController: YoutubeWindowViewController!
    let lineUrl = "https://happy-line-hackday2021.herokuapp.com/linepush"
    let lineUserId = "U069f373b357c50b53247160bbff8bb27"
    
    struct ParseError: Error {}
    
    let userDataKey = "userHeartBeats"
    var userDefaults = UserDefaults.standard
    var userData: [String] = []
    
    var connector = WatchConnector()
    var previousRate = 0.0
    
    let maxDefault = 0.0
    let minDefault = 200.0
    let avgDefault = 0.0
    let grdDefault = 0.0
    let timeThreshold = 180 // 直近の心拍数変動を観測する秒数
    let pplThreshold = 1 // 正規分布仮定法を利用するための最低データ数

    @IBOutlet weak var MessageLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!

    func setTabBar() {
        let images = [
            UIImage(named: "home"),
            UIImage(named: "music")
        ]
        tabBarController?.tabBar.items?.enumerated().forEach {
            $1.image = images[$0]?.withRenderingMode(.alwaysTemplate)
            $1.selectedImage = images[$0]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBar()
        // 心拍数の時系列データを取得
        userData = userDefaults.array(forKey: self.userDataKey) as? [String] ?? []
        print("Get userData: \(userData)")
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(HomeViewController.timerUpdate), userInfo: nil, repeats: true)
        MessageLabel.blinking()
        StatusLabel.blinking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 心拍数の時系列データを保存
        userDefaults.set(userData, forKey: self.userDataKey)
        print("Set userData: \(userData)")
    }
    
    // 1秒おきに実行する処理
    @objc func timerUpdate() {
        // 心拍数の更新があるか確認
        let currentRate = self.connector.receivedRate
        if currentRate != previousRate {
            // 心拍数の更新があれば、時系列データに追加
            let fact = "{\"ut\":\(self.getTimestamp()),\"rate\":\(currentRate)}"
            userData.append(fact)
            previousRate = currentRate
            print("Update userData: \(userData)")
            
            // ステータス判定
            let status = self.judgeHeartStatus()
            switch status {
            case 0:
                self.StatusLabel.text = "STATUS : 未検知"
            case 1:
                self.StatusLabel.text = "STATUS : 正常"
            case 2:
                self.StatusLabel.text = "STATUS : 緊急 (過呼吸)"
                showPalyer(HappyState.emergency.key())
                postLineMessage(HappyState.emergency.message())
            case 3:
                self.StatusLabel.text = "STATUS : 緊急 (低心拍)"
                showPalyer(HappyState.die.key())
                postLineMessage(HappyState.die.message())
            case 4:
                self.StatusLabel.text = "STATUS : 興奮"
                showPalyer(HappyState.highTension.key())
                postLineMessage(HappyState.highTension.message())
            default:
                self.StatusLabel.text = "STATUS : 未検知"
            }
        }
        self.MessageLabel.text = self.connector.receivedMessage
    }
    
    // 現在時刻(UnixTimestamp)を取得
    func getTimestamp() -> Int {
        let dt = Date()
        let unixtime: Int = Int(dt.timeIntervalSince1970)
        return unixtime
    }
    
    // 心拍数の母集団を正規分布と仮定して平均・標準偏差を算出
    func calculatePopulations() -> [Double] {
        if userData.count < self.pplThreshold {
            return [-1.0, -1.0]
        }
        
        var sum: Double = 0.0
        var population: [Double] = []
        
        // 格納された値をループ
        for idx in (0..<userData.count) {
            var data: [String: Any]
            do {
                data = try self.parse(json: userData[idx])
            } catch {
                return [-1.0, -1.0]
            }
            
            // 心拍数
            let rate: Double = data["rate"] as! Double
            population.append(rate)
            
            sum += rate
        }
        // 平均計算
        let avg = sum / Double(userData.count)
        
        // 標準偏差計算
        var _sum: Double = 0.0
        for idx in (0..<population.count) {
            _sum += pow(population[idx] - avg, 2.0)
        }
        let vrt = _sum / Double(userData.count)
        
        return [avg, sqrt(vrt)]
    }
    
    // ステータス判定処理
    func judgeHeartStatus() -> Int {
        var max: Double = maxDefault
        var min: Double = minDefault
        
        // 平均計算用
        var sum: Double = 0.0
        var count: Int = 0
        
        // 勾配計算用
        var first_rate: Double = 0.0
        var last_rate: Double = 0.0
        var first_ut: Int = 0
        var last_ut: Int = 0

        // 格納された値を降順にループ
        for idx in (0..<userData.count).reversed() {
            var data: [String: Any]
            do {
                data = try self.parse(json: userData[idx])
            } catch {
                return 0
            }
            
            // 現在時刻から timeThreshold 以前のデータは対象外
            let ut: Int = data["ut"] as! Int
            if ut < (getTimestamp() - timeThreshold) {
                break
            }
            
            // 心拍数
            let rate: Double = data["rate"] as! Double
            
            if count == 0 {
                last_rate = rate
                last_ut = ut
            }
            first_rate = rate
            first_ut = ut

            sum += rate
            count += 1
            if max < rate {
                max = rate
            }
            if min > rate {
                min = rate
            }
        }
        // 平均計算
        var avg = avgDefault
        if count != 0 {
            avg = sum / Double(count)
        }
        // 勾配計算
        var grd = grdDefault
        if last_ut != first_ut {
            // 100倍しているのは簡易的な正規化のため (適当)
            grd = 100 * (last_rate - first_rate) / Double(last_ut - first_ut)
        }
        
        // 特徴量の表示
        print("max: \(max)")
        print("min: \(min)")
        print("avg: \(avg)")
        print("grd: \(grd)")
        
        // 正規分布仮定法
        let pval = calculatePopulations()
        if pval[0] < 0 {
            return 0
        }
        let z99 = pval[0] + 2.33 * pval[1]
        let z80 = pval[0] + 0.84 * pval[1]
        let z01 = pval[0] - 2.33 * pval[1]
        print("z99: \(z99)")
        print("z80: \(z80)")
        print("z01: \(z01)")
        
        if avg >= z99 {
            return 2
        } else if avg >= z80 {
            return 4
        } else if avg >= z01 {
            return 1
        } else {
            return 3
        }
    }
    
    // Jsonパース処理
    func parse(json: String) throws -> [String: Any] {
        guard let data = json.data(using: .utf8) else {
             throw ParseError()
         }
        let json = try JSONSerialization.jsonObject(with: data)
        guard let obj = json as? [String: Any] else {
            throw ParseError()
        }
        return obj
    }
    
    @IBAction func 集中力が高まってるよ(_ sender: Any) {
        showPalyer(HappyState.highTension.key())
        postLineMessage(HappyState.highTension.message())
    }
    
    @IBAction func ハッピーフィナーレくるぅ(_ sender: Any) {
        showPalyer(HappyState.die.key())
        postLineMessage(HappyState.die.message())
    }
    
    @IBAction func 緊急事態発生中(_ sender: Any) {
        showPalyer(HappyState.emergency.key())
        postLineMessage(HappyState.emergency.message())
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
    
    @IBAction func tapDebugButton(_ sender: UIButton) {
        sender.isHidden = true
        debugAreaView.isHidden = false
    }
    
}
