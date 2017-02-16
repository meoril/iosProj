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
    // save image to Firebase
    self.fbDataService?.saveImage(image: image, name: name, callback: {(url) in
      if (url != nil){
        // save image localy
        self.saveImageToFile(image: image, name: name)
      }
      // notify the user on complete
      callback(url)
    })
  }
  
  func getImage(urlStr:String, callback:@escaping (UIImage?)->Void){
    // try to get the image from local store
    let url = URL(string: urlStr)
    let localImageName = url!.lastPathComponent
    // try getting the image from the local file, if works, send it back to the callback
    // if not, get the image from firebase
    if let image = self.getImageFromFile(name: localImageName){
      callback(image)
    }else{
      // get the image from Firebase
      self.fbDataService?.getImage(url: urlStr, callback: { (image) in
        if (image != nil){
          // save the image localy
          self.saveImageToFile(image: image!, name: localImageName)
        }
        // return the image to the user
        callback(image)
      })
    }
  }
  
  private func saveImageToFile(image:UIImage, name:String){
    // compress the image to data format with 0.8 compression rate
    if let data = UIImageJPEGRepresentation(image, 0.8) {
      // create the file name and path to store the image in and write the data to it
      let filename = getDocumentsDirectory().appendingPathComponent(name)
      try? data.write(to: filename)
    }
  }
  private func getDocumentsDirectory() -> URL {
    // get the file manager's default directory path
    let paths = FileManager.default.urls(for: .documentDirectory, in:
      .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }
  
  private func getImageFromFile(name:String)->UIImage?{
    // get the path to the image's file and load the image from it
    let filename = getDocumentsDirectory().appendingPathComponent(name)
    return UIImage(contentsOfFile:filename.path)
  }
  
  func getAllClinics(){
    // get last update date from SQL
    let lastUpdateDate = LastUpdateService.getLastUpdateDate(database: self.sqlDataService?.database, table: Clinic.CLINIC_TABLE)
    
    // get all updated records from firebase (the callback will be called each time the
    // firebase data updates and triggers the observe handler)
    self.fbDataService?.getAllClinics(lastUpdateDate, callback: { (clinics) in
      // update the local db
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
      
      // notify all the registered controllers that the clinics list has been updated
      // and load the clinics totalList 
      NotificationCenter.default.post(name: Notification.Name(rawValue:
        notifyClinicListUpdate), object:nil , userInfo:["clinics":totalList])
    })
  }
}
