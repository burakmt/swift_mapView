//
//  ViewController.swift
//  TravelBook
//
//  Created by Bera on 21.11.2019.
//  Copyright © 2019 Bera. All rights reserved.
//

//(!) ÖNEMLİ : Kullanıcının lokasyonunu almak için kesinlikle info.plist üzerinden izin almamız gerekiyor.

import UIKit
//Harita kullanımı için...
import MapKit
//Kullanıcının lokasyonunu almak için...
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    //Konumu yönetmek için tanımlama yapıyoruz
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MapView'in çalışması için gerekli!
        mapView.delegate = self
        //Location'ın çalışması için gerekli
        locationManager.delegate = self
        //Haritada ki konumunun keskinlik derecesini ayarlamak için kullanıyoruz. En iyi keskinlik kCLLocationAccuracyBest kullanarak bulunur.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //Kullanıcıdan lokasyon bilgilerini ne sıkılıkla alacağımızı belirtiyoruz.
        //Sadece uygulama kullanımdayken almak için...
        locationManager.requestWhenInUseAuthorization()
        //Lokasyon bilgilerini almaya başlamak için...
        locationManager.startUpdatingLocation()
        
        //Pinleme işlemi yapabilmek için gesture recognizer ekliyoruz. Uzun basılma durumunun olması için LongPress recognizer kullanıyoruz.
        //(!) Dikkat : UILongPressGestureRecognizer'ın özelliklerine ulaşabilmek için oluşturulan fonksiyonun parametresine kendisinden bir kez daha tanımlama
        //yapmamız gerekiyor.
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(choiseLocation(gestureRecognizer:)))
        //Ne kadar uzun süre basılması gerektiğini söylüyoruz.
        gestureRecognizer.minimumPressDuration = 3
        //Oluşturduğumuz recognizer'ı mapView'e ekliyoruz.
        mapView.addGestureRecognizer(gestureRecognizer)
    }

    @objc func choiseLocation(gestureRecognizer : UILongPressGestureRecognizer){
        //Ekrana basılma anını kontrol ediyoruz.
        if gestureRecognizer.state == .began{
            //Basılan noktanın koordinat değerini mapView üzerinden almak için location fonksiyonu kullanıyoruz.
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            //Dokunulan yerden aldığımız lokasyon değerini nerden aldığını ve neye dönüştüreceğini söylüyoruz.
            let touchCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            //Pini oluşturuyoruz.
            let annation = MKPointAnnotation()
            //Oluşturduğumuz pinin koordinatını belirtiyoruz.
            annation.coordinate = touchCoordinates
            annation.title = "Seçtiğiniz Lokasyon"
            annation.subtitle = "Travel Book Application"
            //Oluşturulan pini mapView'e ekliyoruz.
            self.mapView.addAnnotation(annation)
        }
    }
    //Kullanıcının lokasyon bilgilerine müdahale etmek için...
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Kullanıcının şuanki lokasyon bilgilerini almak için CLLocationCoordinate2D fonksiyonuna parametreden gelen locations değerini giriyoruz.
        //locations değeri anlık olarak kullanıcının lokasyon bilgilerini dizi şeklinde alıyor. Biz 0. değerini alıyoruz çünkü ilk program açıldığında
        //yerini saptamamız yetecektir.
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        //Uygulamayı açtığında kullanıcının koordinat üzerinde nerde olduğunu göstermek için ne kadarlık bir zoom yapmamız gerektiğini ayarlıyoruz.
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        //Lokasyon ayarlarını yaptıktan sonra bunu mapView'e aktarımı yapmak için lokasyon ve zoom değerlerini yazarak bir region oluşturuyoruz.
        let region = MKCoordinateRegion(center: location, span: span)
        //Oluşturduğumuz region'ı setRegion fonksiyonu ile aktarımını yapıyoruz.
        mapView.setRegion(region, animated: true)
    }
}

