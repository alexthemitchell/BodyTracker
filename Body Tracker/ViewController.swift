//
//  ViewController.swift
//  Body Tracker
//
//  Created by Alex Mitchell on 10/22/14.
//  Copyright (c) 2014 Alex Mitchell. All rights reserved.
//

import UIKit
import HealthKit
import LocalAuthentication

class ViewController: UIViewController {
    let healthStore = HKHealthStore()
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var bodyFatField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    @IBAction func didClickSave(sender: AnyObject) {
        weightField.resignFirstResponder()
        bodyFatField.resignFirstResponder()
        var weight = self.weightField.text as NSString
        var bodyFat = self.bodyFatField.text as NSString
        var typesToWrite = NSSet(objects:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass as String),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyFatPercentage as String),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex as String))
        
        var typesToRead = NSSet(object:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight as String))
        
        healthStore.requestAuthorizationToShareTypes(typesToWrite, readTypes: typesToRead, completion: { (success : Bool, error : NSError!) -> Void in
            if success {
                self.saveStats(weight.doubleValue, fatPercent: bodyFat.doubleValue)
                
            }
            
        })
        self.weightField.text = ""
        self.bodyFatField.text = ""
        self.showSuccess()
    }
    
    func showVerify(){
        var context = LAContext()
        var authError : NSErrorPointer = nil
        if (context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: authError)){
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Please verify you own this device", reply: { (success : Bool, error: NSError!) -> Void in
                if (success){
                }
                else {
                    self.showVerify()
                }
            })
            
        }
    }
    
    override func viewDidLoad() {
        showVerify()
    }
    func showSuccess(){
        UIAlertView(title: "Saved!", message: "Your stats have been saved.", delegate: nil, cancelButtonTitle: "Thanks!").show()
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

