//
//  InterfaceController.swift
//  FinaleSample02 WatchKit Extension
//
//  Created by 伊藤 直貴 on 2021/02/20.
//

import WatchKit
import Foundation
import HealthKit


class InterfaceController: WKInterfaceController {

    let healthStore = HKHealthStore()
    let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    let heartRateUnit = HKUnit(from: "count/min")
    var heartRateQuery: HKQuery?
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var messageLabel: WKInterfaceLabel!
    @IBOutlet weak var button: WKInterfaceButton!
    
    var connector = PhoneConnector()
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        self.button.setTitle("Start")
        self.label.setText("")
        self.messageLabel.setText("")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // HealthKitがデバイス上で利用できるか確認
        guard HKHealthStore.isHealthDataAvailable() else {
            self.label.setText("not available")
            return
        }
        
        // アクセス許可をユーザに求める
        let dataTypes = Set([HKQuantityType.quantityType(forIdentifier:HKQuantityTypeIdentifier.heartRate)!])
        self.healthStore.requestAuthorization(toShare: nil, read: dataTypes, completion: { (success, error) -> Void in
            guard success else {
                self.label.setText("not allowed")
                return
            }
        })
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    @IBAction func buttonPushed() {
        if heartRateQuery == nil {
            self.heartRateQuery = self.createStreamingQuery()
            self.healthStore.execute(self.heartRateQuery!)
            self.button.setTitle("Stop")
            self.messageLabel.setText("Measuring...")
        } else {
            self.healthStore.stop(self.heartRateQuery!)
            self.heartRateQuery = nil
            self.button.setTitle("Start")
            self.messageLabel.setText("")
            self.label.setText("")
        }
    }
    
    private func createStreamingQuery() -> HKQuery {
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil)
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit), resultsHandler: { (query, samples, deletedObject, anchor, error) -> Void in
            NSLog("samples.count: " + String(samples!.count))
            self.addSamples(samples: samples)
        })
        query.updateHandler = { (query, samples, deletedObject, anchor, error) -> Void in
            NSLog("samples count: " + String(samples!.count))
            self.addSamples(samples: samples)
        }
        return query
    }
    
    private func addSamples(samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
        guard let quantity = samples.last?.quantity else {
            return
        }
        self.messageLabel.setText("Done")
        let msgRate = "\(quantity.doubleValue(for: heartRateUnit))"
        self.label.setText(msgRate)
        self.connector.sendMessage(msg: msgRate)
    }
}
