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
    @IBOutlet weak var flightIndicator: UILabel!
    @IBOutlet weak var flightStepper: UIStepper!
    
    @IBAction func didClickAddFlights(sender: AnyObject) {
        addFlights(flightStepper.value)
    }
    
    @IBAction func didClickSave(sender: AnyObject) {
        weightField.resignFirstResponder()
        bodyFatField.resignFirstResponder()
        var weight = self.weightField.text as NSString
        var bodyFat = self.bodyFatField.text as NSString
        
        requestAuthorization()
        self.saveStats(weight.doubleValue, fatPercent: bodyFat.doubleValue)
        
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
    func requestAuthorization(){
        var typesToWrite = NSSet(objects:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass as String),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyFatPercentage as String),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex as String),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed))
        
        var typesToRead = NSSet(object:
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight as String))
        healthStore.requestAuthorizationToShareTypes(typesToWrite, readTypes: typesToRead, completion: { (success : Bool, error : NSError!) -> Void in
            println("Authorization Requested")
        })
        
    }
    
    @IBAction func didChangeFlightCount(sender: AnyObject) {
        flightIndicator.text = "\(Int(flightStepper.value))" + (flightStepper.value == 1.0 ? " Flight" : " Flights")
        
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
    func addFlights(flights : Double) {
        requestAuthorization()
        var flightObject = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed as String)
        var entry = HKQuantitySample(type: flightObject, quantity: HKQuantity(unit: HKUnit.countUnit(), doubleValue: flights), startDate: NSDate(), endDate: NSDate())
        healthStore.saveObject(entry, withCompletion: { (success: Bool, error: NSError!) -> Void in
            if (success){
                println("Saved \(flights) new flights climbed")
                self.showSuccess()
                self.flightIndicator.text = "1 Flight"
                self.flightStepper.value = 1.0
            }
            else {
                println(error.userInfo)
            }
        })
    }
    func BMI(inches : Double, weight: Double) -> Double {
        return 0
    }
}

