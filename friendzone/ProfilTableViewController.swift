//
//  ProfilTableViewController.swift
//  friendzone
//
//  Created by root root on 03/03/2017.
//  Copyright © 2017 Friend Zone Corporation. All rights reserved.
//

import UIKit

class ProfilTableViewController: UITableViewController {
    var config = Config()
    @IBOutlet var email_input: UITextField!
    @IBOutlet var phone_input: UITextField!
    @IBOutlet var pseudo_input: UITextField!
    @IBOutlet var first_name_input: UITextField!
    @IBOutlet var name_input: UITextField!
    @IBOutlet var updateBtn: UIButton!
    
    var connect_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = self.config.defaults.string(forKey: "name")
        {
            connect_id = name
        }
        self.loadProfil()
        
        //Enlever le clavier
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let clavier = UIToolbar(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 30)))
        clavier.barStyle = UIBarStyle.default
        view.addGestureRecognizer(tap)
    }
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func updateClick(_ sender: Any) {
      
        //Penser à faire le contrôle de saisis
        
        let name : String = name_input.text!
        let first_name : String = first_name_input.text!
        let pseudo : String = pseudo_input.text!
        let phone : String = phone_input.text!
        let mail : String = email_input.text!
        
        loadData(Name : name, First_Name : first_name, Pseudo : pseudo, Phone : phone, Mail : mail)
        
    }
    public func loadProfil(){
        let urlApi = "\(config.url)action=user_profil_ios&values[id]=\(self.connect_id)"
//        let urlApi = "\(config.url)action=user_profil_ios&values[id]=5"
        if let url = URL(string: urlApi){
            URLSession.shared.dataTask(with: url){(myData, response, error) in
                guard let myData = myData, error == nil else{
                    print("error")
                    return
                }
                do{
                    let root = try JSONSerialization.jsonObject(with: myData, options: .allowFragments)
                    if let json = root as? [[String : AnyObject]]{
                        for item in json{
                            if let name = item["nom"] as? String, let first_name = item["prenom"] as? String,
                                let mail = item["mail"] as? String, let phone = item["tel"] as? String,
                                let pseudo = item["pseudo"] as? String{
                                
                                //Redirection
                                DispatchQueue.main.async {
                                    self.name_input.text = name
                                    self.first_name_input.text = first_name
                                    self.email_input.text = mail
                                    self.phone_input.text = phone
                                    self.pseudo_input.text = pseudo
                                }
                                
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
    
    public func loadData(Name : String, First_Name : String, Pseudo : String, Phone : String, Mail : String){
        
        let urlApi = "\(config.url)action=update_profil_ios&values[id]=\(connect_id)&values[nom]=\(Name)&values[prenom]=\(First_Name)&values[tel]=\(Phone)&values[pseudo]=\(Pseudo)&values[mail]=\(Mail)"
        print("API")
        print(urlApi)
        print("API")
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
                                self.alertPrint(TitleController: "Succès", MsgController: "Vos informations ont bien été mis à jour", Titlealt: "Fermer", TableView: self)
                            }else{
                                self.alertPrint(TitleController: "Echec", MsgController: "Une erreur est apparue. Impossible de modifier vos informations. Réessayez ultérieurement!", Titlealt: "Fermer", TableView: self)
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
    
    func alertPrint(TitleController: String,MsgController: String, Titlealt: String, TableView: UITableViewController) -> Void {
        
        let alert = UIAlertController(title: TitleController, message: MsgController,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Titlealt, style: .default, handler: nil))
        
        TableView.present(alert, animated: true, completion: nil)
        
    }
    
}
