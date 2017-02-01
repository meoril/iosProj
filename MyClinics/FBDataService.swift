//
//  FBDataService.swift
//  MyClinics
//
//  Created by Meori Lehr on 31/01/2017.
//  Copyright © 2017 meori.noa. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage


class FBDataService{
  
  
  init(){
    FIRApp.configure()
  }
  
  // setting the storage url (for uploading and downloading images with fb)
  lazy var storageRef = FIRStorage.storage().reference(forURL:
    "gs://myclinics-82979.appspot.com/")
  
  func addClinic(cl:Clinic, completionBlock:@escaping (Error?)->Void){
    let ref = FIRDatabase.database().reference().child("clinics").childByAutoId()
    ref.setValue(cl.toFirebase())
    ref.setValue(cl.toFirebase()){(error, dbref) in
      completionBlock(error)
    }
  }
  
  func saveImage(image:UIImage, name:(String), callback:@escaping (String?)->Void){
    let filesRef = storageRef.child(name)
    if let data = UIImageJPEGRepresentation(image, 0.8) {
      filesRef.put(data, metadata: nil) { metadata, error in
        if (error != nil) {
          callback(nil)
        } else {
          let downloadURL = metadata!.downloadURL()
          callback(downloadURL?.absoluteString)
        }
      }
    }
  }
  
  func getImage(url:String, callback:@escaping (UIImage?)->Void){
    let ref = FIRStorage.storage().reference(forURL: url)
    ref.data(withMaxSize: 10000000, completion: {(data, error) in
      if (error == nil && data != nil){
        let image = UIImage(data: data!)
        callback(image)
      }else{
        callback(nil)
      }
    })
  }
  
  func getAllClinics(_ lastUpdateDate:Date? , callback:@escaping ([Clinic])->Void){
    let handler = {(snapshot:FIRDataSnapshot) in
      var clinics = [Clinic]()
      for child in snapshot.children.allObjects{
        if let childData = child as? FIRDataSnapshot{
          if let json = childData.value as? Dictionary<String,Any>{
            let clinic = Clinic(json: json)
            clinics.append(clinic)
          }
        }
      }
      callback(clinics)
    }
    
    let ref = FIRDatabase.database().reference().child("clinics")
    if (lastUpdateDate != nil){
      print("q starting at:\(lastUpdateDate!) \(lastUpdateDate!.toFirebase())")
      let fbQuery = ref.queryOrdered(byChild:"lastUpdate").queryStarting(atValue:lastUpdateDate!.toFirebase())
      fbQuery.observe(FIRDataEventType.value, with: handler)
    }else{
      ref.observe(FIRDataEventType.value, with: handler)
    }

  }

}
