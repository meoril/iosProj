//
//  SQLDataService.swift
//  MyClinics
//
//  Created by Meori Lehr on 31/01/2017.
//  Copyright © 2017 meori.noa. All rights reserved.
//

import Foundation
import UIKit

class SQLDataService{
  var database: OpaquePointer? = nil
  
  init?(){
    let dbFileName = "database9.db"
    if let dir = FileManager.default.urls(for: .documentDirectory, in:
      .userDomainMask).first{
      let path = dir.appendingPathComponent(dbFileName)
      
      if sqlite3_open(path.absoluteString, &database) != SQLITE_OK {
        print("Failed to open db file: \(path.absoluteString)")
        return nil
      }
    }
    
    if Clinic.createTable(database: database) == false{
      return nil
    }
    if LastUpdateService.createTable(database: database) == false{
      return nil
    }
  }
}
