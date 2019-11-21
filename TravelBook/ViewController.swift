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
import CoreData


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var subTitleText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    //Konumu yönetmek için tanımlama yapıyoruz
    var locationManager = CLLocationManager()
    var annationTitle = "New Annation"
    var annationSubtitle = "New Annation Subtitle"
    var choiseLatitude = Double()
    var choiseLongitude = Double()
    
    var selectedTitle = String()
    var selectedID = UUID()
    
    var annationLatitude = Double()
    var annationLongitude = Double()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
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
        
        if selectedTitle != ""{
            saveButton.isHidden = true
            titleText.isEnabled = false
            subTitleText.isEnabled = false
            let idString = selectedID.uuidString
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "Travel")
            fetchResult.predicate = NSPredicate(format: "id = %@", idString)
            
            do{
                let result = try context.fetch(fetchResult)
                if result.count > 0{
                    for item in result as! [NSManagedObject]{
                        annationTitle = selectedTitle
                        if let dataSubtitle = item.value(forKey: "subtitle") as? String{
                            annationSubtitle = dataSubtitle
                            if let dataLatitude = item.value(forKey: "latitude") as? Double{
                                annationLatitude = dataLatitude
                                if let dataLongitude = item.value(forKey: "longitude") as? Double{
                                    annationLongitude = dataLongitude
                                    
                                    let annation = MKPointAnnotation()
                                    annation.title = annationTitle
                                    annation.subtitle = annationSubtitle
                                    let coordinate = CLLocationCoordinate2D(latitude: annationLatitude, longitude: annationLongitude)
                                    annation.coordinate = coordinate
                                    
                                    mapView.addAnnotation(annation)
                                    titleText.text = annationTitle
                                    subTitleText.text = annationSubtitle
                                    
                                    //Kullanıcı eski kayıtı açtığında locationManager'ı durduruyoruz. Harita değişmini kaldırmak için
                                    locationManager.stopUpdatingLocation()
                                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    let region = MKCoordinateRegion(center: coordinate, span: span)
                                    
                                    mapView.setRegion(region, animated: true)
                                }
                            }
                        }
                        
                    }
                }
            }
            catch{
                    print("Error")
            }
        }
    }
    //Haritada bulunan pinlerin biçimini değiştiriyoruz ve eklemeler yapıyoruz.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //Varsayılan kullanıcının lokasyonunda ki pini kaldırıyoruz.
        if annotation is MKUserLocation{
            return nil
        }
        
        let reuseId = "myAnnation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        //Daha önceden pin oluşturulmuş mu diye kontrol ediyoruz.
        if pinView == nil{
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.tintColor = UIColor.black
            //Oluşturduğumuz pine tıklanınca daha fazla seçenek göstermek istiyorsak balon içerisinde bu özelliği true yapıyoruz.
            pinView?.canShowCallout = true
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            //Oluşturulan pine tıklanan balonun sağ kısmında detay işaretli bir buton oluşturup onu ekliyoruz.
            pinView?.rightCalloutAccessoryView = button
        }
        else{
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    //Navigasyona aktarım ve aradaki mesafeyi katetme işlemi için uygulanan fonksiyon
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedTitle != ""{
            let requestLocation = CLLocation(latitude: annationLatitude, longitude: annationLongitude)
            //Navigasyon temel ayar -> placemarks objesi alabilmek için kullanıyoruz.
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, err) in
                //closure
                if let placemark = placemarks{
                    if placemark.count > 0{
                        //Navigasyonu açmak için MapItem fonksiyonuna bir placemark objesi göndermemiz gerektiğinden dolayı bu şekilde kullanıyoruz.
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        //Navigasyonu açabilmemiz için MapItem oluşturmak gerekiyor
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.annationTitle
                        //MapItem ile açtığımız navigasyonu hangi modda açacağımızı belirtiyoruz.MKLaunchOptionsDirectionsModeDriving -> Araba ile gitme
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        //Navigasyonu açmamızı sağlayan fonksiyon
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
    @objc func choiseLocation(gestureRecognizer : UILongPressGestureRecognizer){
        //Ekrana basılma anını kontrol ediyoruz.
        if gestureRecognizer.state == .began{
            //Basılan noktanın koordinat değerini mapView üzerinden almak için location fonksiyonu kullanıyoruz.
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            //Dokunulan yerden aldığımız lokasyon değerini nerden aldığını ve neye dönüştüreceğini söylüyoruz.
            let touchCoordinates = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            choiseLatitude = touchCoordinates.latitude
            choiseLongitude = touchCoordinates.longitude
            //Pini oluşturuyoruz.
            let annation = MKPointAnnotation()
            //Oluşturduğumuz pinin koordinatını belirtiyoruz.
            annation.coordinate = touchCoordinates
            
            annationTitle = titleText.text == "" ? "New Annation" : titleText.text!
            annationSubtitle = subTitleText.text == "" ? "New Annation Subtitle" : subTitleText.text!
            
            annation.title = annationTitle
            annation.subtitle = annationSubtitle
            //Oluşturulan pini mapView'e ekliyoruz.
            self.mapView.addAnnotation(annation)
            saveButton.isEnabled = true
        }
    }
    //Kullanıcının lokasyon bilgilerine müdahale etmek için...
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle == ""{
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
    @IBAction func saveClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newTravelBook = NSEntityDescription.insertNewObject(forEntityName: "Travel", into: context)
        newTravelBook.setValue(UUID(), forKey: "id")
        newTravelBook.setValue(annationTitle, forKey: "title")
        newTravelBook.setValue(annationSubtitle, forKey: "subtitle")
        newTravelBook.setValue(choiseLatitude, forKey: "latitude")
        newTravelBook.setValue(choiseLongitude, forKey: "longitude")
        
        do{
            try context.save()
            NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
            navigationController?.popViewController(animated: true)
        }
        catch{
            print("Save Error")
        }
    }
}

