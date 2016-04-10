//
//  DBFactory.swift
//  PassbyOrNot
//
//  Created by CHIBANG QN on 4/10/16.
//  Copyright © 2016 Consiiii. All rights reserved.
//

import Foundation
import RealmSwift

struct GLOBAL {
    static var UUID = "416C0120-5960-4280-A67C-A2A9BB166D0F"
    static var USER_INFO: UserInfo?
    static var BEACON : BeaconController?
    static var LIST_SUM = 13
}

public enum ModelType: Int {
    case UserInfo     = 0
    case MeetHistory    = 1
}

public enum DefaultData: String{
    case FirstTimeLogin   =  "FirstTimeLogin"
    case InitNotification = "InitNotification"
}

public class DBFactory {
    
    static var _REALM_:Realm? = nil
    
    static var _MODEL_MAX_ID_ = [Int:Int]()
    
    static var _CONFIG_ = Realm.Configuration(
        schemaVersion: 4,
        // 设置闭包，这个闭包将会在打开低于上面所设置版本号的 Realm 数据库的时候被自动调用
        migrationBlock: { migration, oldSchemaVersion in
            // 目前我们还未进行数据迁移，因此 oldSchemaVersion == 0
            //            if (oldSchemaVersion < 1) {
            //                // 什么都不要做！Realm 会自行检测新增和需要移除的属性，然后自动更新硬盘上的数据库架构
            //            }
        }
    )
    
    static let _APP_GROUP_ID_ = "Chin.PassbyOrNot"
    
    static public func saveDataInUserDefaults(value: String, key: String){
        let userDefault = NSUserDefaults(suiteName: _APP_GROUP_ID_)
        userDefault?.setValue(value, forKey: key)
    }
    
    static public func getDataInUserDefaults(key: String) -> String?{
        let userDefault = NSUserDefaults(suiteName: _APP_GROUP_ID_)
        if let target = userDefault?.valueForKey(key) as? String{
            return target
        }
        return nil
    }
    
    
    static public func requestRealm(ID: String = "") -> Realm?{
        showRealmPath()
        let fileManager = NSFileManager.init()
//        let containerURL = fileManager.containerURLForSecurityApplicationGroupIdentifier(self._APP_GROUP_ID_)
//        let containerPath = containerURL?.URLByAppendingPathComponent("default.realm").path
//        self._CONFIG_.path = containerPath
        
        let realm = try! Realm(configuration: _CONFIG_)
        return realm
        if(_REALM_ == nil){
            
            if(ID == ""){
                _REALM_ =  try! Realm(configuration: _CONFIG_)
                return _REALM_
            }else{
                _CONFIG_.path = NSURL.fileURLWithPath(_CONFIG_.path!).URLByDeletingLastPathComponent?.URLByAppendingPathComponent("\(ID).realm").path
                //                Realm.Configuration.defaultConfiguration = config
                _REALM_ = try! Realm(configuration: _CONFIG_)
                return _REALM_
            }
        }
        return _REALM_
    }
    
    static public func showRealmPath(){
//        #if DEBUG
//            print("Realm Path is \(_CONFIG_.path)")
//        #endif
    }
    
    static public func maxId(Model: ModelType, Obj: Object.Type) -> Int?{
        if let _ = _MODEL_MAX_ID_[Model.rawValue]{
            //Do Nothing
        }else{
            if let tmp = _REALM_?.objects(Obj).max("id") as Int?{
                _MODEL_MAX_ID_[Model.rawValue] = tmp
            }else{
                _MODEL_MAX_ID_[Model.rawValue] = 0
            }
        }
        return _MODEL_MAX_ID_[Model.rawValue]
    }
    
    static public func maxIdAndIncrementThen(Model: ModelType, Obj: Object.Type) -> Int?{
        let max = DBFactory.maxId(Model, Obj: Obj)
        _MODEL_MAX_ID_[Model.rawValue] = _MODEL_MAX_ID_[Model.rawValue]! + 1
        return max
    }
    
    static public func setId(Model: ModelType, Id: Int) -> Int{
        _MODEL_MAX_ID_[Model.rawValue] = Id
        return Id
    }
    
    static public func cleanAllData() -> Bool{
        let realm = DBFactory.requestRealm()
        
        try! realm!.write {
            realm!.deleteAll()
        }
        
        return true
        
    }
}