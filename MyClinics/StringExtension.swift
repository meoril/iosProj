//
//  StringExtension.swift
//  MyClinics
//
//  Created by Meori Lehr on 01/02/2017.
//  Copyright © 2017 meori.noa. All rights reserved.
//

import UIKit

extension String {
  // validates the string format from unsage pointer. for more info check this thread:
  // http://stackoverflow.com/questions/39533320/swift-3-convert-a-null-terminated-unsafepointeruint8-to-a-string
  public init?(validatingUTF8 cString: UnsafePointer<UInt8>) {
    if let (result, _) = String.decodeCString(cString, as: UTF8.self,
                                              repairingInvalidCodeUnits: false) {
      self = result
    }
    else {
      return nil
    }
  }
}
