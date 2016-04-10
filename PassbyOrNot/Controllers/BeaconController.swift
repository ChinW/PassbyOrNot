//
//  BeaconController.swift
//  PassbyOrNot
//
//  Created by CHIBANG QN on 4/10/16.
//  Copyright © 2016 Consiiii. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreLocation

class BeaconController: NATMonitoringOperationDelegate, NATAdvertisingOperationDelegate, NATRangingOperationDelegate {
    
    public var detectedBeacons = [CLBeacon]()
    // The Operation objects
    /// The monitoring operation object.
    public var monitoringOperation = NATMonitoringOperation()
    /// The advertising operation object.
    public var advertisingOperation = NATAdvertisingOperation()
    /// The ranging operation object.
    public var rangingOperation = NATRangingOperation()
    public var delegateViewController: UIViewController?
    
    var previousBeaconsIdentify = Set<String>()
//    var beaconControl : BeaconController?
    
    init() {
//        beaconControl = GLOBAL.BEACON
        // We need to assign self as a delegate here.
        monitoringOperation.delegate = self
        advertisingOperation.delegate = self
        rangingOperation.delegate = self
        
    }
    
    func newPasserbyPopup(userName: String, userImage: UIImage){
        if let delegateViewController = delegateViewController{
            let PasserbyVC = PasserbyPopupViewController(nibName: "PasserbyPopup", bundle: nil)
            PasserbyVC.view.center = delegateViewController.view.center
            PasserbyVC.preparedImage = userImage
            PasserbyVC.userName = userName
            PasserbyVC.modalPresentationStyle = .OverCurrentContext
            delegateViewController.presentViewController(PasserbyVC, animated: true, completion: nil)
        }
    }
    
    func filteredBeacons(beacons: [CLBeacon]) -> [CLBeacon] {
        var filteredBeacons = beacons   // Copy
        var lookup = Set<String>()
        let realm = DBFactory.requestRealm()
        realm?.beginWrite()
        for index in 0..<beacons.count {
            let currentBeacon = beacons[index]
            if currentBeacon.rssi == 0 && currentBeacon.accuracy == -1.0 {
               filteredBeacons.removeAtIndex(index)
//                var maxid = DBFactory.maxIdAndIncrementThen(ModelType.MeetHistory, Obj: MeetHistory.self) ?? 0
//                maxid += 1
//                let tmpImage = UIImagePNGRepresentation(UIImage(named: "headicon")!)!
//                let major = Int(currentBeacon.major)
//                let minor = Int(currentBeacon.minor)
//                let username = "\(currentBeacon.major)\(currentBeacon.minor)"
//                realm?.create(MeetHistory.self, value: [
//                        "id": maxid,
//                        "UUID": currentBeacon.proximityUUID.UUIDString,
//                        "major": major,
//                        "minor": minor,
//                        "imagedata": tmpImage,
//                        "username": username,
//                        "count": 1,
//                        "meetDatetime": NSDate()
//                    ])
                continue
            }
            let identifier = "\(currentBeacon.major)/\(currentBeacon.minor)"
            if lookup.contains(identifier) {//Delete repeated items
                filteredBeacons.removeAtIndex(index)
            } else {
                //If it's a new comer
                if !previousBeaconsIdentify.contains(identifier){
                    //and the distance is limit by 0.5 meter, push it
                    if(currentBeacon.accuracy < 0.5){
                        lookup.insert(identifier)
                        sendLocalNotificationForBeacon(currentBeacon)
                    }else{
                        //do nothing
                    }
                }else{
                    lookup.insert(identifier)
                }
            }
        }
        try! realm?.commitWrite()
        previousBeaconsIdentify = lookup
        return filteredBeacons
    }
    
    func changeMonitoringState(monitoringSwitch: UISwitch) {
//        beaconControl?.changeMonitoringState(monitoringSwitch)
        monitoringSwitch.on ? monitoringOperation.startMonitoringForBeacons() : monitoringOperation.stopMonitoringForBeacons()
    }
    
    func changeAdvertisingState(advertisingSwitch: UISwitch) {
//        beaconControl?.changeMonitoringState(advertisingSwitch)

        advertisingSwitch.on ? advertisingOperation.startAdvertisingBeacon() : advertisingOperation.stopAdvertisingBeacon()
    }
    
    func changeRangingState(rangingSwitch: UISwitch) {
//        beaconControl?.changeMonitoringState(rangingSwitch)
        rangingSwitch.on ? rangingOperation.startRangingForBeacons() : rangingOperation.stopRangingForBeacons()
    }
    
    func monitoringOperationDidStartSuccessfully() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //            self.monitoringSwitch.on = true
            //            self.monitoringActivityIndicator.startAnimating()
        }
    }
    func monitoringOperationDidStopSuccessfully() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //            self.monitoringActivityIndicator.stopAnimating()
        }
    }
    
    func monitoringOperationDidFailToStart() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //            self.monitoringSwitch.on = false
        }
    }
    
    /**
     Triggered by the monitoring operation when it has failed to start due to the last authorization denial.
     
     It turns the monitoring switch off and presents a UIAlertView to prompt the user to change their location
     access settings.
     */
    func monitoringOperationDidFailToStartDueToAuthorization() {
        let title = "Missing Location Access"
        let message = "Location Access (Always) is required. Click Settings to update the location access settings."
        let cancelButtonTitle = "Cancel"
        let settingsButtonTitle = "Settings"
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction.init(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: settingsButtonTitle, style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        if let delegateViewController = delegateViewController {
            delegateViewController.presentViewController(alertController, animated: true, completion: nil)
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //            self.monitoringSwitch.on = false
        }
    }
    
    /**
     Triggered by the monitoring operation when it has detected entering the provided region. It emits
     a local notification.
     
     :param: region The provided region that the monitoring operation detected.
     */
    func monitoringOperationDidDetectEnteringRegion(region: CLBeaconRegion) {
        print("monitoringOperationDidDetectEnteringRegion")
        sendLocalNotificationForBeaconRegion(region)
    }
    
    func sendLocalNotificationForBeacon(beacon: CLBeacon) {
        let notification = UILocalNotification()
        notification.alertBody = "Meet someone for UUID: \(beacon.major) \(beacon.minor)"
        notification.alertAction = "View Details"
        notification.hasAction = true
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
        self.newPasserbyPopup("\(beacon.major) \(beacon.minor)", userImage: UIImage(named: "headicon")!)
    }
    
    /**
     Emits a UILocalNotification with information about the given region.
     
     Note that major and minor are not available at the monitoring stage.
     
     :param: region The given CLBeaconRegion instance.
     */
    func sendLocalNotificationForBeaconRegion(region: CLBeaconRegion) {
        let notification = UILocalNotification()
        notification.alertBody = "Entered beacon region for UUID: " + region.proximityUUID.UUIDString
        notification.alertAction = "View Details"
        notification.hasAction = true
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
        self.newPasserbyPopup(region.proximityUUID.UUIDString, userImage: UIImage(named: "headicon")!)
    }
    
    func advertisingOperationDidStartSuccessfully() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //            self.advertisingSwitch.on = true
            //            self.advertisingActivityIndicator.startAnimating()
        }
    }
    
    /**
     Triggered by the advertising operation when it has stopped successfully and turns the activity indicator off.
     */
    func advertisingOperationDidStopSuccessfully() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //            self.advertisingActivityIndicator.stopAnimating()
        }
    }
    
    /**
     Triggered by the advertising operation when ithas failed to start and turns the advertising switch off.
     */
    func advertisingOperationDidFailToStart() {
        let title = "Bluetooth is off"
        let message = "It seems that Bluetooth is off. For advertising to work, please turn Bluetooth on."
        let cancelButtonTitle = "OK"
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction.init(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction);
        
        if let delegateViewController = delegateViewController {
            delegateViewController.presentViewController(alertController, animated: true, completion: nil)
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //            self.advertisingSwitch.on = false
        }
    }
    /**
     Triggered by the ranging operation when it has started successfully. It turns the ranging switch on
     and resets the detectedBeacons array.
     */
    func rangingOperationDidStartSuccessfully() {
        detectedBeacons = []
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //            self.rangingSwitch.on = true
        }
    }
    
    /**
     Triggered by the ranging operation when it has failed to start and turns the ranging switch off.
     */
    func rangingOperationDidFailToStart() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //            self.rangingSwitch.on = false
        }
    }
    
    /**
     Triggered by the ranging operation when it has failed to start due to the last authorization denial.
     
     It turns the ranging switch off and presents a UIAlertView to prompt the user to change their location
     access settings.
     */
    func rangingOperationDidFailToStartDueToAuthorization() {
        let title = "Missing Location Access"
        let message = "Location Access (When In Use) is required. Click Settings to update the location access settings."
        let cancelButtonTitle = "Cancel"
        let settingsButtonTitle = "Settings"
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction.init(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel, handler: nil)
        let settingsAction = UIAlertAction.init(title: settingsButtonTitle, style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(cancelAction);
        alertController.addAction(settingsAction);
        
        if let delegateViewController = delegateViewController {
            delegateViewController.presentViewController(alertController, animated: true, completion: nil)
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            //            self.rangingSwitch.on = false
        }
    }
    
    /**
     Triggered by the ranging operation when it has stopped successfully. It updates the beacon table view to reflect
     that the ranging has stopped.
     */
    func rangingOperationDidStopSuccessfully() {
        detectedBeacons = []
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            //            self.beaconTableView.beginUpdates()
            //            if let deletedSections = self.deletedSections() {
            //                self.beaconTableView.deleteSections(deletedSections, withRowAnimation: UITableViewRowAnimation.Fade)
            //            }
            //            self.beaconTableView.endUpdates()
            
        }
    }
    
    /**
     Triggered by the ranging operation when it has detected beacons belonging to a specific given beacon region.
     
     It updates the table view to show the newly-found beacons.
     
     :param: beacons An array of provided beacons that the ranging operation detected.
     :param: region A provided region whose beacons the operation is trying to range.
     */
    func rangingOperationDidRangeBeacons(beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let filteredBeacons = self.filteredBeacons(beacons as! [CLBeacon])
            
            if filteredBeacons.isEmpty {
                print("No beacons found nearby.")
            } else {
                let beaconsString: String
                
                if filteredBeacons.count > 1 {
                    beaconsString = "beacons"
                } else {
                    beaconsString = "beacon"
                }
                print("Found \(filteredBeacons.count) \(beaconsString).")
            }
            
            if let mainTVC = self.delegateViewController as? MainTableViewController {
                mainTVC.beacons = filteredBeacons
            }
        }
    }
}

// MARK: - CLBeacon extension
extension CLBeacon
{
    /**
     Returns a specially-formatted description of the beacon's characteristics.
     
     :returns: The beacon's description.
     */
    func fullDetails() -> String {
        let proximityText: String
        
        switch proximity {
        case .Near:
            proximityText = "周围"
        case .Immediate:
            proximityText = "非常近"
        case .Far:
            proximityText = "较远"
        case .Unknown:
            proximityText = "未知"
        }
        
        if(rssi == 0){
            print("Distance already gets zero")
        }
        
        print("\(major), \(minor) •  \(proximityText) • \(accuracy) • \(rssi)")
        
        return " \(proximityText) • 约\(accuracy)米 "
    }
}