//
//  ConfigTableViewController.swift
//  PassbyOrNot
//
//  Created by CHIBANG QN on 4/9/16.
//  Copyright © 2016 Consiiii. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreLocation

class ConfigTableViewController: UITableViewController {
    
    @IBOutlet weak var monitoringSwitch: UISwitch!
    @IBOutlet weak var advertisingSwitch: UISwitch!
    @IBOutlet weak var rangingSwitch: UISwitch!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var headImage: UIImageView!
    
    var beaconControl : BeaconController?
    
    private enum NTSectionType: Int {
        case UserInfo = 0
        case Operations
        
        func cellIdentifier() -> String {
            switch self {
            case .UserInfo:
                return "UserInfo"
            case .Operations:
                return "Operations"
            }
        }
        
        func tableViewCellHeight() -> CGFloat {
            switch self {
            case .UserInfo:
                return 84.0
            case .Operations:
                return 44.0
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userinfo = GLOBAL.USER_INFO {
                
        }else{
            UserInfo.getUserData()
        }
        headImage.image = UIImage(data: (GLOBAL.USER_INFO?.imagedata)!)
        monitoringSwitch.on = (GLOBAL.USER_INFO?.montoringSwitch)!
        rangingSwitch.on = (GLOBAL.USER_INFO?.rangingSwitch)!
        advertisingSwitch.on = (GLOBAL.USER_INFO?.advertisingSwitch)!
        username.text = (GLOBAL.USER_INFO?.username)
        if let beacon = GLOBAL.BEACON {
            beaconControl = GLOBAL.BEACON
        }else{
            GLOBAL.BEACON = BeaconController()
            beaconControl = GLOBAL.BEACON
        }
        
        self.title = "Settings"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
    }

    override func viewDidAppear(animated: Bool) {
        beaconControl?.delegateViewController = self
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 84
        }
        return 44
//        return NTSectionType(rawValue: indexPath.section)!.tableViewCellHeight()
    }
    
    @IBAction func toggleAdvertisingSwitch(sender: AnyObject) {
        beaconControl?.changeAdvertisingState(sender as! UISwitch)
//        changeAdvertisingState(sender as! UISwitch)
    }
    
    @IBAction func toggleMonitoringSwitch(sender: AnyObject) {
        beaconControl?.changeMonitoringState(sender as! UISwitch)
//        changeMonitoringState(sender as! UISwitch)
    }
    
    @IBAction func toggleRangingSwitch(sender: AnyObject) {
        beaconControl?.changeRangingState(sender as! UISwitch)
//        changeRangingState(sender as! UISwitch)
    }
    
}
