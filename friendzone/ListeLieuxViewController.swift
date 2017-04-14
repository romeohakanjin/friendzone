//
//  ListeLieuxViewController.swift
//  friendzone
//
//  Created by rhakanjin on 10/04/2017.
//  Copyright © 2017 julien. All rights reserved.
//

import UIKit
import AudioToolbox
import MapKit
import CoreLocation

class ListeLieuxViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var userPinView: MKAnnotationView!
    var currentLatitude: CLLocationDistance = 0.0
    var currentLongitude: CLLocationDistance = 0.0
    
    var sourceLocation = CLLocationCoordinate2D()
    var destinationLocation = CLLocationCoordinate2D()
    var annotation = MKAnnotationView()
    var config = Config()
    
    var success = false
    var id_user_co = ""
    var lieu_user = [Int: [String: String]]()
    
    override func viewDidLoad() {
        if let name = self.config.defaults.string(forKey: "name")
        {
            id_user_co = name
        }
        loadListLocation()
        sleep(2)
        
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        //Demande autorisation
        locationManager.requestAlwaysAuthorization()
        
        
        //Si l'app est autorisé
        if (CLLocationManager.locationServicesEnabled())
        {
            print("Autoriser")
            
            locationManager.distanceFilter = 100
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            //Fait vibrer le tél
            //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            
            var i=0
            //On fecth les data de endroits_user pour les marqueurs
            if(!self.lieu_user.isEmpty){
                for (key, arr) in self.lieu_user
                {
                    let annot = MKPointAnnotation()
                    annot.title = arr["title"]
                    annot.coordinate = CLLocationCoordinate2D(latitude: Double(arr["latitude"] ?? "") ?? 0.0, longitude: Double(arr["longitude"] ?? "") ?? 0.0)
                    
                    annotation.annotation = annot
                    print("ici annot")
                    print(annot.coordinate)
                    //Ajout du marker
                    mapView.addAnnotation(annotation.annotation!)
                    
                    //AJout lat long pour l'itinéraire
                    destinationLocation.latitude = Double(arr["latitude"] ?? "") ?? 0.0
                    destinationLocation.longitude = Double(arr["longitude"] ?? "") ?? 0.0
                    
                    i += 1
                }
            }
            else{
                print("Tableau d'amis vide")
            }
        }
            
            
        else
        {
            print("Error")
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //Permet d'avoir la position actuelle de l'user
        var location: AnyObject? = locations.last
        currentLatitude = (location?.coordinate.latitude)!
        currentLongitude = (location?.coordinate.longitude)!
        
        centerMap(Float32(currentLatitude), long: Float32(currentLongitude))
        
        mapView.showsUserLocation = true
        
        print(currentLatitude)
        print(currentLongitude)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        // Handle errors here
    }
    
    func centerMap(_ lat:Float32,long : Float32){
        // stock les var dans pos actuelle
        //        var posActuelle = CLLocationCoordinate2D.init()
        //        posActuelle.latitude = CLLocationDegrees(lat)
        //        posActuelle.longitude = CLLocationDegrees(long)
        
        let spanX = 0.03
        let spanY = 0.03
        
        print("Tes")
        sourceLocation.latitude = CLLocationDegrees(lat)
        sourceLocation.longitude = CLLocationDegrees(long)
        
        print(sourceLocation.latitude)
        print(sourceLocation.longitude)
        
        if(!self.lieu_user.isEmpty){
            print(annotation.annotation?.coordinate.longitude)
            print(annotation.annotation?.coordinate.latitude)
            createRoute(sourceLoc: sourceLocation, sourceDest: (annotation.annotation?.coordinate)!)
            
        }
        else{
            print("Tableau de lieu vide donc pas de route")
        }
        
        
        let newRegion = MKCoordinateRegion(center:sourceLocation , span: MKCoordinateSpanMake(spanX, spanY))
        mapView.setRegion(newRegion, animated: true)
    }
    
    func createRoute(sourceLoc : CLLocationCoordinate2D, sourceDest : CLLocationCoordinate2D)
    {
        let request = MKDirectionsRequest()
        
        // parametre de la requete
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: sourceLoc.latitude, longitude: sourceLoc.longitude), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: sourceDest.latitude, longitude: sourceDest.longitude), addressDictionary: nil))
        request.requestsAlternateRoutes = false
        
        //Type d'itinéraire
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate
            {
                response, error in
                print(response)
                
                guard let routes = response?.routes else
                {
                    print(error)
                    return
                }
                
                // Prints affiche les étapes de l'itinéraire
                for r in routes
                {
                    print("New route")
                    for step in r.steps
                    {
                        print("  " + step.instructions)
                    }
                }
                
                //Traçage de l'itinéraire
                let route = response?.routes.first
                
                self.mapView.add((route?.polyline)!, level: MKOverlayLevel.aboveRoads)
                
                //self.mapView.setVisibleMapRect((route?.polyline.boundingMapRect)!, animated: true)
        }
        print("Fin des étapes")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Tracer le ligne
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red:1.00, green:0.27, blue:0.25, alpha:1.0)
        renderer.lineWidth = 1
        
        return renderer
    }
    
    //Ajout du bouton dans la notif
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKUserLocation) {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(annotation.hash))
            
            let rightButton = UIButton(type: .contactAdd)
            rightButton.tag = annotation.hash
            
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            pinView.rightCalloutAccessoryView = rightButton
            
            return pinView
        }
        else {
            return nil
        }
    }
    
    public func loadListLocation() ->Bool
    {
        let urlApi = "\(config.url)action=liste_location&values[id_user]=\(id_user_co)"
        
        if let url =  URL(string: urlApi){
            URLSession.shared.dataTask(with: url){
                (myData, response, error) in
                //guard inverse de if
                guard let myData = myData, error == nil else{
                    //Pas de data ou error
                    print("error")
                    return
                }
                
                do{
                    let root = try JSONSerialization.jsonObject(with: myData, options: .allowFragments)
                    
                    if let json = root as? [ String: AnyObject]
                    {
                        if let result = json["result"] as? [ [String : AnyObject] ]
                        {
                            var i = 0
                            for entry in result
                            {
                                if let id_lieu  = entry["id_lieu"] as! String?,
                                    let id_user  = entry["id_user"] as! String?,
                                    let libelle  = entry["libelle"] as! String?,
                                    let adresse  = entry["adresse"] as! String?,
                                    let longi  = entry["longi"] as! String?,
                                    let lat  = entry["lat"] as! String?{
                                    
                                        self.lieu_user[i] = ["title": libelle, "latitude": lat, "longitude": longi]
                                        i += 1
                                }
                                
                            }
                        }
                    }
                    
                }
                catch{
                    
                    let nsError = error as NSError
                    print(nsError.localizedDescription)
                    
                }
                
                }.resume()
        }
        
        return self.success
        
    }
}
