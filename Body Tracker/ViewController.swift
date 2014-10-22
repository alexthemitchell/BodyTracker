//
//  ViewController.swift
//  Body Tracker
//
//  Created by Alex Mitchell on 10/22/14.
//  Copyright (c) 2014 Alex Mitchell. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    let healthStore = HKHealthStore()
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var bodyFatField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    @IBAction func didClickSave(sender: AnyObject) {
        var typesToWrite = NSSet(objects:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass as String),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyFatPercentage as String),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex as String))
        
        var typesToRead = NSSet(object:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight as String))
        
        healthStore.requestAuthorizationToShareTypes(typesToWrite, readTypes: typesToRead, completion: { (success : Bool, error : NSError!) -> Void in
            if success {
                self.saveStats((self.weightField.text as NSString).doubleValue, fatPercent: (self.bodyFatField.text as NSString).doubleValue)
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func saveStats(weight: Double, fatPercent : Double){
        if (weight != 0.0){
            var massObject = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass as String)
            var entry = HKQuantitySample(type: massObject, quantity: HKQuantity(unit: HKUnit(fromString: "lb"), doubleValue: weight), startDate: NSDate(), endDate: NSDate())
            healthStore.saveObject(entry, withCompletion: { (success: Bool, error: NSError!) -> Void in
                if (success){
                    println("Saved Weight")
                }
                else {
                    println(error.userInfo)
                }
            })
        }
        if (fatPercent != 0.0){
            var fatObject = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyFatPercentage as String)
            var entry = HKQuantitySample(type: fatObject, quantity: HKQuantity(unit: HKUnit.percentUnit(), doubleValue: fatPercent/100), startDate: NSDate(), endDate: NSDate())
            healthStore.saveObject(entry, withCompletion: { (success: Bool, error: NSError!) -> Void in
                if (success){
                    println("Saved Fat Percentage")
                }
                else {
                    println(error.userInfo)
                }
            })
            
        }
        
        let heightType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight as String)
    }
    
    func BMI(inches : Double, weight: Double) -> Double {
        return 0
    }
}

