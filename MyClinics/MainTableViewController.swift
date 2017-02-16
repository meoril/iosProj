//
//  MainTableViewController.swift
//  MyClinics
//
//  Created by Meori Lehr on 31/01/2017.
//  Copyright © 2017 meori.noa. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
  var myClinics = [Clinic]()
    let clinicSegueIdentifier = "ShowClinicSegue"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // registering to the clinics list did update notification
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.clinicsListDidUpdate), name: NSNotification.Name(rawValue: notifyClinicListUpdate),object: nil)
    
    // loading the clinics
    DataService.instance.getAllClinics()
  }
  
  @objc func clinicsListDidUpdate(notification:NSNotification){
    self.myClinics = notification.userInfo?["clinics"] as! [Clinic]
    self.tableView!.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.myClinics.count
  }
  
  // for the unwind segue, reload the view in order to show the new clinic
  @IBAction func saveDetails(segue:UIStoryboardSegue) {
    self.tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "myClinicCell", for: indexPath) as! ClinicTableViewCell
    cell.myNameLabel!.text = self.myClinics[indexPath.row].name
    cell.myAddressLabel!.text = self.myClinics[indexPath.row].address
    
    // for each cell load the clinic's image
    if let imUrl = self.myClinics[indexPath.row].imageUrl{
      DataService.instance.getImage(urlStr: imUrl, callback: { (image) in
        cell.myImage!.image = image
      })
    }
    return cell
  }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == clinicSegueIdentifier,
            let destination = segue.destination as? ClinicViewController,
            let clinicIdex = self.tableView.indexPathForSelectedRow?.row
        {
            destination.selectedClinic = myClinics[clinicIdex]
        }
    }
}
