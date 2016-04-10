//
//  MainTableViewController.swift
//  PassbyOrNot
//
//  Created by CHIBANG QN on 4/10/16.
//  Copyright © 2016 Consiiii. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreLocation

class MainTableViewController: UITableViewController {

    
    var beaconControl : BeaconController?
    var beacons = [CLBeacon]() {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    var setWarningCell = false
    
    /// An array of CLBeacon objects, typically those detected through ranging.
    private var detectedBeacons = [CLBeacon]()
    
    override func viewDidLoad() {
        //Check Notification Settings
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        UserInfo.getUserData()
        if let beacon = GLOBAL.BEACON {
            beaconControl = GLOBAL.BEACON
        }else{
            GLOBAL.BEACON = BeaconController()
            beaconControl = GLOBAL.BEACON
        }
        
        self.title = "I Come"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.tabBarController?.tabBar.tintColor =  UIColor(red:0.71, green:0.17, blue:0.16, alpha:1.00)

//        self.tableView.dataSource = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        beaconControl?.delegateViewController = self
        beaconControl?.rangingOperation.startRangingForBeacons()
        beaconControl?.monitoringOperation.startMonitoringForBeacons()
        //Initalisze iBeacon Settings
        //        advertisingSwitch.on = true
        //        monitoringSwitch.on = true
        //        changeMonitoringState(monitoringSwitch)
        //        newPasserbyPopup("Bangqiang CHI", userImage: UIImage(named:"headicon")!)
        //        advertisingSwitch.on = true
        //        print(advertisingSwitch.on)
        //        toggleAdvertisingSwitch(advertisingSwitch)
    }
    
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if beacons.count > 0{
            setWarningCell = false
            return beacons.count
        }
        setWarningCell = true
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if setWarningCell == false{
            let cell = self.tableView.dequeueReusableCellWithIdentifier("BeaconCell") as! BeaconCellinMain
            //        let cell = UITableView(reuseIdentifier: "beaconCell") as! BeaconCellinMain
            let userinfo = beacons[indexPath.section]
            let iconNumber = Int(userinfo.major) % GLOBAL.LIST_SUM
            cell.cellImage.image = UIImage(named: "rsz_head\(iconNumber)")
            cell.cellTitle.text = "隔壁老王\(userinfo.major) :\(userinfo.minor) "
            print(indexPath.section)
            cell.cellDetail.text = userinfo.fullDetails()
            return cell
        }else{
            let cell = self.tableView.dequeueReusableCellWithIdentifier("ReminderCell")
            return cell!
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if setWarningCell == false{
            return 90
        }
        else{
            return 250
        }
    }
}

