//
//  Clinic.swift
//  MyClinics
//
//  Created by Meori Lehr on 31/01/2017.
//  Copyright © 2017 meori.noa. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Clinic {
  var name:String
  var address:String
  var imageUrl:String?
  var latitude:Double
  var longitude:Double
  var lastUpdate:Date?
  
  init(name:String, address:String, latitude:Double, longitude:Double, imageUrl:String? = nil){
    self.name = name
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    self.imageUrl = imageUrl
  }

  init(json:Dictionary<String,Any>){
    name = json["name"] as! String
    address = json["address"] as! String
    latitude = json["latitude"] as! Double
    longitude = json["longitude"] as! Double
    if let im = json["imageUrl"] as? String{
      imageUrl = im
    }
    if let ts = json["lastUpdate"] as? Double{
      self.lastUpdate = Date.fromFirebase(ts)
    }
  }
  
  func toFirebase() -> Dictionary<String,Any> {
    var json = Dictionary<String,Any>()
    json["name"] = name
    json["address"] = address
    json["latitude"] = latitude
    json["longitude"] = longitude
    if (imageUrl != nil){
      json["imageUrl"] = imageUrl!
    }
    json["lastUpdate"] = FIRServerValue.timestamp()
    return json
  }
  
  /* SQL Part Start */
  static let CLINIC_TABLE = "CLINICS"
  //static let CLINIC_ID = "CLINIC_ID"
  static let CLINIC_NAME = "NAME"
  static let CLINIC_ADDRESS = "ADDRESS"
  static let CLINIC_LATITUDE = "LATITUDE"
  static let CLINIC_LONGITUDE = "LONGITUDE"
  static let CLINIC_IMAGE_URL = "IMAGE_URL"
  static let CLINIC_LAST_UPDATE = "CLINIC_LAST_UPDATE"
  
  
  static func createTable(database:OpaquePointer?)->Bool{
    var errormsg: UnsafeMutablePointer<Int8>? = nil
    
    let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + CLINIC_TABLE + " ( " + CLINIC_NAME + " TEXT PRIMARY KEY, "
      + CLINIC_ADDRESS + " TEXT, "
      + CLINIC_LATITUDE + " DOUBLE, "
      + CLINIC_LONGITUDE + " DOUBLE, "
      + CLINIC_IMAGE_URL + " TEXT, "
      + CLINIC_LAST_UPDATE + " DOUBLE)", nil, nil, &errormsg);
    if(res != 0){
      print("error creating table");
      return false
    }
    
    return true
  }
  
  func addClinicToLocalDb(database:OpaquePointer?){
    var sqlite3_stmt: OpaquePointer? = nil
    if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Clinic.CLINIC_TABLE
      + "(" + Clinic.CLINIC_NAME + ","
      + Clinic.CLINIC_ADDRESS + ","
      + Clinic.CLINIC_LATITUDE + ","
      + Clinic.CLINIC_LONGITUDE + ","
      + Clinic.CLINIC_IMAGE_URL + ","
      + Clinic.CLINIC_LAST_UPDATE + ") VALUES (?,?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
      
      let name = self.name.cString(using: .utf8)
      let address = self.address.cString(using: .utf8)
      let latitude = self.latitude
      let longitude = self.longitude
      var imageUrl = "".cString(using: .utf8)
      if self.imageUrl != nil {
        imageUrl = self.imageUrl!.cString(using: .utf8)
      }
      
      sqlite3_bind_text(sqlite3_stmt, 1, name,-1,nil);
      sqlite3_bind_text(sqlite3_stmt, 2, address,-1,nil);
      sqlite3_bind_double(sqlite3_stmt, 3, latitude);
      sqlite3_bind_double(sqlite3_stmt, 4, longitude);
      sqlite3_bind_text(sqlite3_stmt, 5, imageUrl,-1,nil);
      if (lastUpdate == nil){
        lastUpdate = Date()
      }
      sqlite3_bind_double(sqlite3_stmt, 6, lastUpdate!.toFirebase());
      
      if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
        print("new row added succefully")
      }
    }
    sqlite3_finalize(sqlite3_stmt)
  }
  
  static func getAllClinicsFromLocalDb(database:OpaquePointer?)->[Clinic]{
    var clinics = [Clinic]()
    var sqlite3_stmt: OpaquePointer? = nil
    if (sqlite3_prepare_v2(database,"SELECT * from CLINICS;",-1,&sqlite3_stmt,nil) == SQLITE_OK){
      while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
        let name =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,0))
        let address =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,1))
        let latitude =  Double(sqlite3_column_double(sqlite3_stmt,2))
        let longitude =  Double(sqlite3_column_double(sqlite3_stmt,3))
        var imageUrl =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,4))
        
        print("read from filter st:  \(name) \(address) \(latitude) \(longitude) \(imageUrl)")
        if (imageUrl != nil && imageUrl == ""){
          imageUrl = nil
        }
        let clinic = Clinic(name: name!, address: address!, latitude: latitude, longitude: longitude, imageUrl: imageUrl)
      clinics.append(clinic)
      }
    }
    sqlite3_finalize(sqlite3_stmt)
    return clinics
  }
  /* SQL Part End */
}
