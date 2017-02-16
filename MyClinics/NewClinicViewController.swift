//
//  NewClinicViewController.swift
//  MyClinics
//
//  Created by Meori Lehr on 31/01/2017.
//  Copyright © 2017 meori.noa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class NewClinicViewController: UIViewController , UIImagePickerControllerDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
  
  @IBOutlet weak var myNameLabel: UITextField!
  @IBOutlet weak var myAddressLabel: UITextField!
  @IBOutlet weak var myMap: MKMapView!
  @IBOutlet weak var myImageView: UIImageView!
  @IBOutlet weak var mySaveButton: UIBarButtonItem!
  @IBOutlet weak var myRecommendation: UITextView!
  
  let imagePicker = UIImagePickerController()
  var locationManager = CLLocationManager()
  var currLocation = CLLocation()
  var selectedLatitude: Double = 0
  var selcetedLongitude: Double = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.myNameLabel.delegate = self
    self.myAddressLabel.delegate = self
    self.imagePicker.delegate = self
    
    self.mySaveButton.isEnabled = false
    
    // 	ask for user's permission to use location
    self.locationManager.requestWhenInUseAuthorization()
    
    // get current location
    if CLLocationManager.locationServicesEnabled(){
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation()
      currLocation = locationManager.location!
    }
    
    // set the starting point and initial zoom span of the mapkit
    let span = MKCoordinateSpanMake(0.0075, 0.0075)
    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.currLocation.coordinate.latitude, longitude: self.currLocation.coordinate.longitude), span: span)
    self.myMap.setRegion(region, animated: true)
    
    // set the event for long press gesture (defined by minimumPressDuration property)
    // for adding the annotation
    let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(self.action(gestureRecognizer:)))
    uilgr.minimumPressDuration = 1.0
    self.myMap.addGestureRecognizer(uilgr)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // long press on map gesture handler
  func action(gestureRecognizer:UIGestureRecognizer){
    // clear existing annotations if any
    self.myMap.removeAnnotations(self.myMap.annotations)
    
    // get the point to add annotation to
    let touchPoint = gestureRecognizer.location(in: self.myMap)
    
    //add the annotation where the user pressed
    let newCoordinates = self.myMap.convert(touchPoint, toCoordinateFrom: self.myMap)
    let annotation = MKPointAnnotation()
    annotation.coordinate = newCoordinates
    self.selectedLatitude = newCoordinates.latitude
    self.selcetedLongitude = newCoordinates.longitude
    self.myMap.addAnnotation(annotation)
    self.mySaveButton.isEnabled = self.validateInputs()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    self.mySaveButton.isEnabled = self.validateInputs()
    return true
  }
  
  private func validateInputs() -> Bool {
    return self.myNameLabel.text != "" && self.myAddressLabel.text != "" && self.myImageView.image != nil
      && self.selcetedLongitude != 0 && self.selectedLatitude != 0
  }
  
//  @objc func clinicsListDidUpdate(notification:NSNotification){
//    let clinics = notification.userInfo?["clinics"] as! [Clinic]
//    for clinic in clinics {
//      print("name: \(clinic.name) \(clinic.lastUpdate!)")
//    }
//  }
//  
  /*************  Image loader section  ****************/
  
  @IBAction func myLoadImage_Clicked(_ sender: UIButton) {
    self.imagePicker.allowsEditing = false
    self.imagePicker.sourceType = .photoLibrary
    
    present(self.imagePicker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.myImageView.contentMode = .scaleAspectFit
      self.myImageView.image = pickedImage
      self.mySaveButton.isEnabled = self.validateInputs()
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  //  func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
  //
  //  }
  
  /*************  Image loader section end  ****************/
  
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    DataService.instance.saveImage(image: self.myImageView.image!, name: self.myNameLabel.text!){(url) in
      
        DataService.instance.addClinic(clinic: Clinic(name: self.myNameLabel.text!, address: self.myAddressLabel.text!,
                                                     latitude: self.selectedLatitude,longitude: self.selcetedLongitude, imageUrl: url,  recommendation: self.myRecommendation.text ))
    }
  }
}
