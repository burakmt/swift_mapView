//
//  ViewController.swift
//  TravelBook
//
//  Created by Bera on 21.11.2019.
//  Copyright © 2019 Bera. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MapView'in çalışması için gerekli!
        mapView.delegate = self
    }


}

