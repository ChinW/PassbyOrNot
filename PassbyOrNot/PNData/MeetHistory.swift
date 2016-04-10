//
//  MeetHistory.swift
//  PassbyOrNot
//
//  Created by CHIBANG QN on 4/10/16.
//  Copyright © 2016 Consiiii. All rights reserved.
//

import Foundation
import RealmSwift

class MeetHistory: Object {
    
//    public dynamic var id: Int = 0
    public dynamic var UUID = ""
    public dynamic var major : Int = 0
    public dynamic var minor : Int = 0
    public dynamic var imagedata: NSData?
    public dynamic var username = ""
    public dynamic var count : Int = 0
    public dynamic var meetDatetime = NSDate()
    public dynamic var create_at = NSDate()
    
//    override public static func primaryKey() -> String? {
//        return "id"
//    }
    
}
