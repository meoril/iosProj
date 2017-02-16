//
//  ClinicViewController.swift
//  MyClinics
//
//  Created by Noa Tsror on 07/02/2017.
//  Copyright © 2017 meori.noa. All rights reserved.
//

import UIKit
import MapKit

class ClinicViewController: UIViewController {

    @IBOutlet weak var clinicAddressLbl: UILabel!
    @IBOutlet weak var clinicNameLable: UILabel!
    @IBOutlet weak var clinicImage: UIImageView!
    @IBOutlet weak var clinicRecomm: UILabel!

    var selectedClinic = Clinic(name:"",address:" ",latitude:0.0,longitude:0.0,recommendation:" ");
    
    @IBAction func button(_ sender: UIButton) {
        let coordinates = CLLocationCoordinate2DMake(selectedClinic.latitude,
                                                     selectedClinic.longitude)
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapitem = MKMapItem(placemark: placemark)
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapitem.openInMaps(launchOptions: options)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        clinicNameLable.text = selectedClinic.name
        clinicAddressLbl.text = selectedClinic.address
        clinicRecomm.text = selectedClinic.recommendation
        
        
        if let imUrl = selectedClinic.imageUrl{
            DataService.instance.getImage(urlStr: imUrl, callback: { (image) in
                self.clinicImage!.image = image
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
