//
//  DataService.swift
//  MyClinics
//
//  Created by Meori Lehr on 31/01/2017.
//  Copyright © 2017 meori.noa. All rights reserved.
//

import Foundation
import UIKit

let notifyClinicListUpdate = "com.meori.noa.NotifyClinicListUpdate"

class DataService {
  static let instance = DataService()
  
  lazy private var sqlDataService:SQLDataService? = SQLDataService()
  lazy private var fbDataService:FBDataService? = FBDataService()
  
  func addClinic(clinic: Clinic){
    self.fbDataService?.addClinic(cl: clinic){(error) in
    }
  }
  
  func saveImage(image:UIImage, name:String, callback:@escaping (String?)->Void){
    //1. save image to Firebase
    self.fbDataService?.saveImage(image: image, name: name, callback: {(url) in
      if (url != nil){
        //2. save image localy
        self.saveImageToFile(image: image, name: name)
      }
      //3. notify the user on complete
      callback(url)
    })
  }
  
  func getImage(urlStr:String, callback:@escaping (UIImage?)->Void){
    //1. try to get the image from local store
    let url = URL(string: urlStr)
    let localImageName = url!.lastPathComponent
    if let image = self.getImageFromFile(name: localImageName){
      callback(image)
    }else{
      //2. get the image from Firebase
      self.fbDataService?.getImage(url: urlStr, callback: { (image) in
        if (image != nil){
          //3. save the image localy
          self.saveImageToFile(image: image!, name: localImageName)
        }
        //4. return the image to the user
        callback(image)
      })
    }
  }
  
  private func saveImageToFile(image:UIImage, name:String){
    if let data = UIImageJPEGRepresentation(image, 0.8) {
      let filename = getDocumentsDirectory().appendingPathComponent(name)
      try? data.write(to: filename)
    }
  }
  private func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in:
      .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }
  
  private func getImageFromFile(name:String)->UIImage?{
    let filename = getDocumentsDirectory().appendingPathComponent(name)
    return UIImage(contentsOfFile:filename.path)
  }
  
  func getAllClinicsAndObserve(){
    // get last update date from SQL
    let lastUpdateDate = LastUpdateService.getLastUpdateDate(database: self.sqlDataService?.database, table: Clinic.CLINIC_TABLE)
    
    // get all updated records from firebase
    self.fbDataService?.getAllClinics(lastUpdateDate, callback: { (clinics) in
      //update the local db
      print("got \(clinics.count) new records from FB")
      var lastUpdate:Date?
      for clinic in clinics{
        clinic.addClinicToLocalDb(database: self.sqlDataService?.database)
        if lastUpdate == nil{
          lastUpdate = clinic.lastUpdate
        }else{
          if lastUpdate!.compare(clinic.lastUpdate!) == ComparisonResult.orderedAscending{
            lastUpdate = clinic.lastUpdate
          }
        }
      }
      
      //upadte the last update table
      if (lastUpdate != nil){
        LastUpdateService.setLastUpdate(database: self.sqlDataService!.database, table: Clinic.CLINIC_TABLE, lastUpdate: lastUpdate!)
      }
      
      //get the complete list from local DB
      let totalList = Clinic.getAllClinicsFromLocalDb(database: self.sqlDataService?.database)
      
      //return the list to the observers using notification center
      NotificationCenter.default.post(name: Notification.Name(rawValue:
        notifyClinicListUpdate), object:nil , userInfo:["clinics":totalList])
    })
  }
}
