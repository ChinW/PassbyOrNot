//
//  UserInfo.swift
//  PassbyOrNot
//
//  Created by CHIBANG QN on 4/10/16.
//  Copyright © 2016 Consiiii. All rights reserved.
//

import Foundation
import RealmSwift

public class UserInfo: Object {
    
    public dynamic var id: Int = 0
    public dynamic var UUID = ""
    public dynamic var major : Int = 0
    public dynamic var minor : Int = 0
    public dynamic var username = ""
    public dynamic var imagedata : NSData?
    public dynamic var montoringSwitch : Bool = true
    public dynamic var advertisingSwitch : Bool = false
    public dynamic var rangingSwitch : Bool = true
    public dynamic var create_at = NSDate()
    
    static public func getUserData() -> UserInfo{
        let realm = DBFactory.requestRealm()
        let users =  realm?.objects(UserInfo)
        if users!.count < 1{
            try! realm?.write(){
                let uuidString = NSUUID().UUIDString
                let major = arc4random_uniform(5000)
                let minor = arc4random_uniform(5000)
                let iconNumber = Int(major) % GLOBAL.LIST_SUM
                
                let defaultImage = UIImagePNGRepresentation(UIImage(named: "rsz_head\(iconNumber)")!)!
                
                let maxid = DBFactory.maxIdAndIncrementThen(.UserInfo, Obj: UserInfo.self) ?? 0
                realm?.create(UserInfo.self, value: [
                    "id": maxid + 1,
                    "UUID": uuidString,
                    "major": Int(major),
                    "minor": Int(minor),
                    "username": "隔壁老王\(major)",
                    "imagedata": defaultImage,
                    ])
            }
            GLOBAL.USER_INFO = self.getUserData()
//            return self.getUserData()
        }else{
            GLOBAL.USER_INFO = users!.last!
//            return users!.last!
        }
        return GLOBAL.USER_INFO!
        
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
