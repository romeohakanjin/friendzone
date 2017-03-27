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
    @IBOutlet var pseudo_input: UITextField!
    @IBOutlet var first_name_input: UITextField!
    @IBOutlet var phone_input: UITextField!
    @IBOutlet var name_input: UITextField!
    @IBOutlet var updateBtn: UIButton!
    
    var connect_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = self.config.defaults.string(forKey: "name")
        {
            self.connect_id = name
        }
        
        //Bloquer la modification des champs quand on arrive sur la page
        self.name_input.isUserInteractionEnabled = false
        self.first_name_input.isUserInteractionEnabled = false
        self.email_input.isUserInteractionEnabled = false
        self.phone_input.isUserInteractionEnabled = false
        self.pseudo_input.isUserInteractionEnabled = false
        self.loadProfil()
        
        //Enlever le clavier
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //Action liée au bouton Modifier
    @IBAction func updateClick(_ sender: Any) {
        
        //Penser à faire le contrôle de saisis
        
        let name : String = name_input.text!
        let first_name : String = first_name_input.text!
        let pseudo : String = pseudo_input.text!
        let phone : String = phone_input.text!
        let mail : String = email_input.text!
        
        if(updateBtn.currentTitle == "Modifier"){
            //Débloquer la modification des champs quand on arrive sur la page
            self.name_input.isUserInteractionEnabled = true
            self.first_name_input.isUserInteractionEnabled = true
            self.email_input.isUserInteractionEnabled = true
            self.phone_input.isUserInteractionEnabled = true
            self.pseudo_input.isUserInteractionEnabled = true
            updateBtn.setTitle("Enregistrer", for: .normal)
        }else if(updateBtn.currentTitle == "Enregistrer"){
            updateProfil(Name : name, First_Name : first_name, Pseudo : pseudo, Phone : phone, Mail : mail)
        }
    }
    
    //Permet d'afficher le profil
    public func loadProfil(){
        let urlApi = "\(config.url)action=user_profil_ios&values[id]=\(self.connect_id)"
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
    
    //Permet de faire les modifications d'informations du profil
    public func updateProfil(Name : String, First_Name : String, Pseudo : String, Phone : String, Mail : String){
        
        let urlApi = "\(config.url)action=update_profil_ios&values[id]=\(connect_id)&values[nom]=\(Name)&values[prenom]=\(First_Name)&values[tel]=\(Phone)&values[pseudo]=\(Pseudo)&values[mail]=\(Mail)"
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
                                msgAlert = "Vos informations ont bien été mis à jour"
                                
                            }else{
                                titleAlert = "Echec"
                                msgAlert = "Une erreur est apparue. Impossible de modifier vos informations. Réessayez ultérieurement!"
                                
                            }
                            DispatchQueue.main.async {
                                self.alertPrint(TitleController: titleAlert, MsgController: msgAlert, Titlealt: "Fermer", TableView: self)
                                self.name_input.isUserInteractionEnabled = false
                                self.first_name_input.isUserInteractionEnabled = false
                                self.email_input.isUserInteractionEnabled = false
                                self.phone_input.isUserInteractionEnabled = false
                                self.pseudo_input.isUserInteractionEnabled = false
                                self.loadProfil()
                                self.updateBtn.setTitle("Modifier", for: .normal)
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
    
    //Permet d'afficher un message de confirmation
    func alertPrint(TitleController: String,MsgController: String, Titlealt: String, TableView: UITableViewController) -> Void {
        
        let alert = UIAlertController(title: TitleController, message: MsgController,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Titlealt, style: .default, handler: nil))
        
        TableView.present(alert, animated: true, completion: nil)
        
    }
    
}
