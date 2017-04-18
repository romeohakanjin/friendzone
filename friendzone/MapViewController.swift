//
//  MapViewController.swift
//  friendzone
//
//  Created by Julien on 04/04/2017.
//  Copyright © 2017 rhakanjin. All rights reserved.
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
    var annotation = MKAnnotationView()
    var config = Config()
    
    var success = false
    var id_user_co = ""
    var endroits_user = [Int: [String: String]]()
    var latitude_user : Double = 0.0
    var longitude_user : Double = 0.0
    var libelle_lieu : String = ""
    
    @IBOutlet weak var btnPartage: UISwitch!
    @IBOutlet weak var LabelPartage: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
    }
    
    override func viewDidLoad() {
        if let name = self.config.defaults.string(forKey: "name")
        {
            id_user_co = name
        }
        loadData()
        getPartage()
        sleep(1)
        
        
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        //Demande autorisation
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
        //Si l'app est autorisé
        if (CLLocationManager.locationServicesEnabled())
        {
            print("Autoriser")
            
            locationManager.distanceFilter = 100
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            var i=0
            
            //On fecth les data de endroits_user pour les marqueurs
            if(!self.endroits_user.isEmpty){
                //Fait vibrer le tél
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                
                for (key, arr) in self.endroits_user
                {
                    print("ICI QUIL FAUT REGARDER")
                    print(arr["latitude"]!)
                    print(arr["longitude"]!)
                    
                    let annot = MKPointAnnotation()
                    annot.title = arr["title"]
                    annot.coordinate = CLLocationCoordinate2D(latitude: Double(arr["latitude"] ?? "") ?? 0.0, longitude: Double(arr["longitude"] ?? "") ?? 0.0)
                
                    annotation.annotation = annot
                
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
        /*
        print(currentLatitude)
        print(currentLongitude)
        print("CA BOUGE CA BOUGE CA BOUGE")
        print("CA BOUGE CA BOUGE CA BOUGE")
        print("CA BOUGE CA BOUGE CA BOUGE")
        print("CA BOUGE CA BOUGE CA BOUGE")
        
        let alert = UIAlertController(title: "information", message: "CA BOUGE CA BOUGE", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Fermer", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        */
        
        updateLocation(latitude: currentLatitude, longitude: currentLongitude);
        
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
        
        if(!self.endroits_user.isEmpty){
            print(annotation.annotation?.coordinate.longitude)
            print(annotation.annotation?.coordinate.latitude)
            createRoute(sourceLoc: sourceLocation, sourceDest: (annotation.annotation?.coordinate)!)

        }
        else{
            print("Tableau d'amis vide donc pas de route")
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
    
    public func loadData() ->Bool
    {
        let urlApi = "\(config.url)action=user_position&values[id]=\(id_user_co)"
        
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
                        if let result = json["result"] as? [ [String : String] ]
                        {
                            var i = 0
                            for entry in result
                            {
                                if let idAmiEntry  = entry["id_ami"] as String?,
                                    let idUserEntry  = entry["id_user"] as String?,
                                    let nomAmi  = entry["nom_ami"] as String?,
                                    let prenomAmi  = entry["prenom_ami"] as String?,
                                    let tel  = entry["tel"] as String?,
                                    let pseudoAmi  = entry["pseudo_ami"] as String?,
                                    let longAmi  = entry["long_ami"] as String?,
                                    let latAmi  = entry["lat_ami"] as String?
                                {
                                    self.endroits_user[i] = ["title": nomAmi+" "+prenomAmi, "latitude": latAmi, "longitude": longAmi]
                                    i += 1
                                }
                            }
                            print("ICI ENDROIT USER")
                            print(self.endroits_user)
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
    
    func getPartage() {
        
        var id_co = ""
        
        if let name = self.config.defaults.string(forKey: "name")
        {
            id_co = name
        }
        
        let url = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php/?fichier=users&action=amis_liste&values[id]=\(id_co)"
        if let url = URL(string: url){
            URLSession.shared.dataTask(with: url) { (Mdata, res, err) in
                
                guard let Mdata = Mdata , err == nil else
                {
                    return
                }
                
                do{
                    
                    let json = try JSONSerialization.jsonObject(with: Mdata, options: .allowFragments)
                    var part = "1"
                    if let root = json as? [String : AnyObject]{
                        if let feed = root["result"] as? [[String : AnyObject]]{
                            for item in feed {
                                
                                if let item = item["par"]
                                {
                                    if item as! String == "0" {
                                        part = "0"
                                    }
                                }
                                else
                                {
                                    print("Other")
                                }
                                
                            }
                        }
                    }
                    
                    if(part == "1"){
                        DispatchQueue.main.async(execute:{
                            self.LabelPartage.text = "Supprimer ma position"
                            self.btnPartage.setOn(true, animated: true)
                        })
                    }else{
                        DispatchQueue.main.async(execute:{
                            self.LabelPartage.text = "Partager ma position"
                            self.btnPartage.setOn(false, animated: true)
                        })
                    }
                    
                }catch{
                    
                }
                }.resume()
        }
    }
    
    @IBAction func SendPart(_ sender: Any) {
        
        PartagePos()
        
    }
    
    public func PartagePos()
    {
        
        var id_co = ""
        var partage = ""
        
        if(self.btnPartage.isOn){
            partage = "1"
        }else{
            partage = "0"
        }
        
        
        if let name = self.config.defaults.string(forKey: "name")
        {
            id_co = name
        }
        
        let url = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php/?fichier=users&action=Update_Share_Pos&values[par]=\(partage)&values[id]=\(id_co)"
        
        if let url = URL(string: url){
            
            URLSession.shared.dataTask(with: url) { (Mdata, res, err) in
                
                guard let Mdata = Mdata , err == nil else
                {
                    return
                }
                
                do{
                    
                    let json = try JSONSerialization.jsonObject(with: Mdata, options: .allowFragments)
                    
                    if let root = json as? [String : AnyObject]{
                        if let feed = root["result"] as? [[String : AnyObject]]{
                            for item in feed {
                                
                                if let item = item["par"]
                                {
                                    print("item : \(item)")
                                }
                                else
                                {
                                    print("Other")
                                }
                                
                            }
                        }
                    }
                    
                }catch{
                    
                }
                }.resume()
        }
    }
    
    @IBAction func partagerUnLieu(_ sender: UIButton) {
        
        
        latitude_user = locationManager.location?.coordinate.latitude as Double!
        longitude_user = locationManager.location?.coordinate.longitude as Double!
        
        print(latitude_user)
        print(longitude_user)
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Ajout d'un lieu", message: "Saisir le nom du lieu", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.libelle_lieu = (textField?.text)!
            
            if(self.libelle_lieu != ""){
                print(self.libelle_lieu)
                self.getAddressWithLatlong()
            }
            else{
                let alert = UIAlertController(title: "Erreur", message: "Nom de lieu incorrect", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Fermer", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    //Have the address according to the longitude and latitude of the online user
    func getAddressWithLatlong(){
        let longitude :CLLocationDegrees = longitude_user
        let latitude :CLLocationDegrees = latitude_user
        var address_user : String = ""
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if (error != nil) {
                print("Reverse geocoder failed with error\(error?.localizedDescription)")
                return
            }
            
            if ((placemarks?.count)! > 0) {
                let pm = placemarks?[0]
                address_user = (pm?.locality)!
                
                self.shareLocation(adresse : address_user)
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    //Permet d'ajouter un lieu
    public func shareLocation(adresse : String){
        
        var urlApi = "\(config.url)action=share_location_ios&values[id_user]=\(self.id_user_co)&values[libelle]=\(self.libelle_lieu)&values[adresse]=\(adresse)&values[longi]=\(self.longitude_user)&values[lat]=\(self.latitude_user)"
        urlApi = urlApi.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        
        if let url =  URL(string: urlApi){
            URLSession.shared.dataTask(with: url){(myData, response, error) in
                guard let myData = myData, error == nil else{
                    print("error")
                    return
                }
                do{
                    let root = try JSONSerialization.jsonObject(with: myData, options: .allowFragments)
                    if let json = root as? [String : AnyObject]{
                        for item in json{
                            //Affichage message en fonction du code erreur récupéré
                            let error_code = item.value as! String
                            var titleAlert = ""
                            var msgAlert = ""
                            if(error_code == "ok"){
                                titleAlert = "Succès"
                                msgAlert = "Lieu partagé!"
                                
                            }else{
                                titleAlert = "Echec"
                                msgAlert = "Une erreur est apparue. Impossible d'ajouter le lieu. Réessayez ultérieurement!"
                                
                            }
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: titleAlert, message: msgAlert, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Fermer", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                               
                            }
                        }
                    }
                }
                catch{
                    let errorCatched = error as NSError
                    print("error")
                    print(errorCatched.localizedDescription)
                    print("end error")
                }
                }.resume()
        }
    }
    
    //Permet d'actualiser sa position en BDD
    public func updateLocation(latitude : Double, longitude : Double){
        
        var urlApi = "\(config.url)action=update_position_ios&values[id]=\(self.id_user_co)&values[lat]=\(latitude)&values[longi]=\(longitude)"
        urlApi = urlApi.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
        
        if let url =  URL(string: urlApi){
            URLSession.shared.dataTask(with: url){(myData, response, error) in
                guard let myData = myData, error == nil else{
                    print("error")
                    return
                }
                do{
                    let root = try JSONSerialization.jsonObject(with: myData, options: .allowFragments)
                    if let json = root as? [String : AnyObject]{
                        for item in json{
                            //Affichage message en fonction du code erreur récupéré
                            let error_code = item.value as! String
                            
                            if(error_code == "ok"){
                                print("Succès partage position en BDD")
                                
                            }else{
                                print("Echec update position")
                            }
                        }
                    }
                }
                catch{
                    let errorCatched = error as NSError
                    print("error")
                    print(errorCatched.localizedDescription)
                    print("end error")
                }
                }.resume()
        }
    }
}
