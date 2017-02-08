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
    
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.clinicsListDidUpdate), name: NSNotification.Name(rawValue: notifyClinicListUpdate),object: nil)
    DataService.instance.getAllClinicsAndObserve()
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
  
  // for the unwind segue, reload the view in order to show the new student
  @IBAction func saveDetails(segue:UIStoryboardSegue) {
    self.tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "myClinicCell", for: indexPath) as! ClinicTableViewCell
    cell.myNameLabel!.text = self.myClinics[indexPath.row].name
    cell.myAddressLabel!.text = self.myClinics[indexPath.row].address
    
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
    
    
    
  
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
