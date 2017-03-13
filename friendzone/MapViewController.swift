//
//  MapViewController.swift
//  friendzone
//
//  Created by Julien on 06/03/2017.
//  Copyright © 2017 julien. All rights reserved.
//

import UIKit
import AudioToolbox
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var userPinView: MKAnnotationView!
    var currentLatitude: CLLocationDistance = 0.0
    var currentLongitude: CLLocationDistance = 0.0
    
    var sourceLocation = CLLocationCoordinate2D()
    var destinationLocation = CLLocationCoordinate2D()
    var annotation = MKPointAnnotation()
    var config = Config()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager.delegate = self
        //Demande autorisation
        locationManager.requestAlwaysAuthorization()
        
        if let name = self.config.defaults.string(forKey: "name")
        {
            print("----------")
            print(name)
        }
        
        //Si l'app est autorisé
        if (CLLocationManager.locationServicesEnabled())
        {
            print("Autoriser")
            
            locationManager.distanceFilter = 100
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            //Fait vibrer le tél
            //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            
            //Marker
            let endroits = [
                ["title": "New York, NY", "latitude": 40.713054, "longitude": -74.007228],
                ["title": "Shanghai, CH", "latitude": 31.2222200, "longitude": 121.4580600],
                ["title": "Paris, FR", "latitude": 48.866667, "longitude": 2.333333],
                ["title": "test", "latitude": 48.8492, "longitude": 2.2978],
                ]
            
            for marker in endroits
            {
                let annotation = MKPointAnnotation()
                annotation.title = marker["title"] as? String
                annotation.coordinate = CLLocationCoordinate2D(latitude: marker["latitude"] as! Double, longitude: marker["longitude"] as! Double)
                
                //Ajout du marker
                mapView.addAnnotation(annotation)
                
                //AJout lat long pour l'itinéraire
                destinationLocation.latitude = marker["latitude"] as! Double
                destinationLocation.longitude = marker["longitude"] as! Double
                
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
        print("UPDATA")
        
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
        
        print(annotation.coordinate.longitude)
        createRoute(sourceLoc: sourceLocation, sourceDest: annotation.coordinate)
        
        let newRegion = MKCoordinateRegion(center:sourceLocation , span: MKCoordinateSpanMake(spanX, spanY))
        mapView.setRegion(newRegion, animated: true)
    }
    
    func createRoute(sourceLoc : CLLocationCoordinate2D, sourceDest : CLLocationCoordinate2D)
    {
        let request = MKDirectionsRequest()
        
        print(sourceDest.latitude)
        print("&&&&&")
        print(sourceDest.longitude)
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
