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
    
    FIRDatabase.database().persistenceEnabled = true
  }
  
  // setting the storage url (for uploading and downloading images with fb)
  lazy var storageRef = FIRStorage.storage().reference(forURL:
    "gs://myclinics-82979.appspot.com/")
  
  func addClinic(cl:Clinic, completionBlock:@escaping (Error?)->Void){
    // generate an empty child record in the firebase clinics list and return the ref to it
    let ref = FIRDatabase.database().reference().child("clinics").childByAutoId()
    
    // set the new clinic's data on the record ref
    ref.setValue(cl.toFirebase()){(error, dbref) in
      completionBlock(error)
    }
  }
  
  func saveImage(image:UIImage, name:(String), callback:@escaping (String?)->Void){
    let filesRef = storageRef.child(name)
    // convert the uiimage to jpeg with the compression rate
    if let data = UIImageJPEGRepresentation(image, 0.8) {
      // save the image to the firebase storage
      filesRef.put(data, metadata: nil) { metadata, error in
        if (error != nil) {
          callback(nil)
        } else {
          //get the image url in the fb storage
          let downloadURL = metadata!.downloadURL()
          callback(downloadURL?.absoluteString)
        }
      }
    }
  }
  
  func getImage(url:String, callback:@escaping (UIImage?)->Void){
    // get the image ref by the url given
    let ref = FIRStorage.storage().reference(forURL: url)
    // download the image's data async from firebase and on success callback send the image back
    // to the callback given
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
    // creating the code that will parse the data returned from the observe function
    // that loads the clinics from firebase (it will be called on the first call and 
    // for each change to the data in the firebase server)
    let handler = {(snapshot:FIRDataSnapshot) in
      // run on the returned clinics objects and parse them to clinic objects from kv pairs
      var clinics = [Clinic]()
      for child in snapshot.children.allObjects{
        if let childData = child as? FIRDataSnapshot{
          if let json = childData.value as? Dictionary<String,Any>{
            let clinic = Clinic(json: json)
            clinics.append(clinic)
          }
        }
      }
      
      // send the clinics to the callback
      callback(clinics)
    }
    
    // create a ref to the clinics store
    let ref = FIRDatabase.database().reference().child("clinics")
    
    // observe the clinics store
    if (lastUpdateDate != nil){
      let fbQuery = ref.queryOrdered(byChild:"lastUpdate").queryStarting(atValue:lastUpdateDate!.toFirebase())
      fbQuery.observe(FIRDataEventType.value, with: handler)
    }else{
      ref.observe(FIRDataEventType.value, with: handler)
    }

  }

}
