//
//  DataBase.swift
//  TD-ApiExo
//
//  Created by Francis on 30/01/2017.
//  Copyright © 2017 Francis C. All rights reserved.
//


import UIKit
import Contacts

protocol DataBaseDelegateTableAmis  {
    func dataLoaded()
}

class DataBaseTableAmis: NSObject{
    
    var delegate : DataBaseDelegateTableAmis?
    public var list = [ItemTableAmis]()
    var config = Config()
    var url = ""
    var connect_id = ""
    
    let store = CNContactStore()
    var requete = String()
    var img = UIImage()
   
    func loadData(TableView: UITableViewController,Type: Int){
        
        if let name = self.config.defaults.string(forKey: "name")
        {
            connect_id = name
        }
        
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in guard granted else {
                
                self.alertPrint(TitleController:"Pas d'accès aux contacts",MsgController: "Veuillez autoriser l'accès via les paramètres", Titlealt: "OK", TableView: TableView)
                return
                
            }
            
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
            var cnContacts = [CNContact]()
            
            do {
                
                try self.store.enumerateContacts(with: request){ (contact, cursor) -> Void in
                    cnContacts.append(contact)
                }
                
            } catch let error {
                print("Fetch contact error: \(error)")
            }
            
            for contact in cnContacts {
                let nb = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
                
                /*if contact.imageDataAvailable {
                 let img = UIImage(data: contact.imageData!)
                 }*/
                
                //let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
                
                self.requete += "&values[array][]=\(nb)"
                
            }
            if Type == 0{
                 self.url = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php?fichier=users&action=non_friend&\(self.requete)&values[id_user]=\(self.connect_id)"
            }else{
                 self.url = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php/?fichier=users&action=amis_liste&values[id]=\(self.connect_id)"
            }
        
          
            
        if let url = URL(string: self.url){
            
            URLSession.shared.dataTask(with: url) { (Mdata, res, err) in
                
                guard let Mdata = Mdata , err == nil else
                {
                    self.alertPrint(TitleController: "Une erreure est survenue", MsgController: "Relancer l'application", Titlealt: "OK", TableView: TableView)
                    return
                }
                
                
                
                do{
                    
                    let json = try JSONSerialization.jsonObject(with: Mdata, options: .allowFragments)
                    //let d = String(data: Mdata, encoding: String.Encoding.utf8)
                    //print(d)
                    if let root = json as? [String : AnyObject]{
                        if let feed = root["result"] as? [[String : AnyObject]]{
                           
                            
                            for item in feed {
                                let i = ItemTableAmis()
                                
                   
                                    if let item = item["nom_user"]
                                    {
                                        i.nom = item as! String
                                       
                                    }
                                    else
                                    {
                                        print("Other")
                                    }
                                
                                    
                                    if let item = item["tel"]
                                    {
                                        i.nb = item as! String
                                        
                                        self.store.requestAccess(for: .contacts, completionHandler: {
                                            granted, error in guard granted else {
                                                
                                                self.alertPrint(TitleController:"Pas d'accès aux contacts",MsgController: "Veuillez autoriser l'accès via les paramètres", Titlealt: "OK", TableView: TableView)
                                                return
                                                
                                            }
                                            
                                            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactImageDataAvailableKey] as [Any]
                                            let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
                                            var cnContacts = [CNContact]()
                                            
                                            do {
                                                
                                                try self.store.enumerateContacts(with: request){ (contact, cursor) -> Void in
                                                    cnContacts.append(contact)
                                                }
                                                
                                            } catch let error {
                                                print("Fetch contact error: \(error)")
                                            }
                                            
                                            let imageName = "imgdefault.png"
                                            i.img = UIImage(named: imageName)!

                                            
                                            for contact in cnContacts {
                                                
                                                let nb = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
                                                
                                                
                                                if nb == item as! String {
                                                    
                                            
                                                    if contact.imageDataAvailable {
                                                        // there is an image for this contact
                                                        i.img = UIImage(data: contact.imageData!)!
                                                        
                                                        // Do what ever you want with the contact image below
                                                      
                                                    }
                                            
                                                    break
                                                //let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
                                                
                                            }
                                        
                                            }
                                            
                                        })
                                        
                                    }
                                    else
                                    {
                                    
                                        print("Other")
                                    }
                                
                                
                                
                                    if let item = item["id_user"]
                                    {
                                        i.id = item as! String
                                    }
                                    else
                                    {
                                        print("Other")
                                    }
                                
                                
                                
                                    if let item = item["id_ami"]
                                    {
                                        i.id = item as! String
                                    }
                                    else
                                    {
                                        print("Other")
                                    }
                                
                                    if let item = item["par"]
                                    {
                                        i.par = item as! String
                                    }
                                    else
                                    {
                                        print("Other")
                                    }
                                
                                
                               
                                    self.list.append(i)
                                
                                
                                

                            }
                                    DispatchQueue.main.async(execute:{
                                        self.delegate?.dataLoaded()
                                    })
                        
                                
                            }
                        }
        
                    
                    
                }catch{
                    print("Erreur parse")
                }
                
            }.resume()
        }
            
        })
    }



func alertPrint(TitleController: String,MsgController: String, Titlealt: String, TableView: UITableViewController) -> Void {
    
    let alert = UIAlertController(title: TitleController, message: MsgController,preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: Titlealt, style: .default, handler: nil))
    
    TableView.present(alert, animated: true, completion: nil)
    
}
    
func alertPrintRet(TitleController: String,MsgController: String, Url: String ,TableView: UITableViewController) -> Void {
        
        let alert = UIAlertController(title: TitleController, message: MsgController,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Non", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { action in
            
            if let url = URL(string: Url){
                
                URLSession.shared.dataTask(with: url) { (Mdata, res, err) in
                    
                    guard let Mdata = Mdata , err == nil else
                    {
                        self.alertPrint(TitleController: "Une erreure est survenue", MsgController: "Relancer l'application", Titlealt: "OK", TableView: TableView)
                        return
                    }
                    
                    if let d = String(data: Mdata, encoding: String.Encoding.utf8){
                        
                        if d.contains("ok"){
                            self.alertPrint(TitleController: "Vous avez ajouté un amis", MsgController: "Amis ajouté", Titlealt: "OK", TableView: TableView)
                        }else{
                            self.alertPrint(TitleController: "Une erreure est survenue", MsgController: "Relancer l'application", Titlealt: "OK", TableView: TableView)
                        }
                    
                    } else{
                    
                        self.alertPrint(TitleController: "Une erreure est survenue", MsgController: "Relancer l'application", Titlealt: "OK", TableView: TableView)
                    
                    }
                    
                    }.resume()
            }
            
    }))
    
        TableView.present(alert, animated: true, completion: nil)
        
}

    
    func alertPrintAmis(TitleController: String,Par: String, TableView: UITableViewController,IDAMI: String) -> Void {
    
    
        var msgPar = ""
        var urlPar = ""
        var optmsg = ""
        
        if Par == "0"{
             msgPar = "Partager ma position"
             optmsg = "Partagé"
             urlPar = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php?fichier=users&action=partage_position&values[id_user]=\(connect_id)&values[id_ami]=\(IDAMI)&values[partage_pos]=1"
        }else{
              msgPar = "Supprimer ma position"
              optmsg = "Supprimé"
              urlPar = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php?fichier=users&action=partage_position&values[id_user]=\(connect_id)&values[id_ami]=\(IDAMI)&values[partage_pos]=0"
        }
        
        let urlDelete = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php?fichier=users&action=delete_amis&values[id_user]=\(connect_id)&values[id_ami]=\(IDAMI)"
    
        let alert = UIAlertController(title: TitleController, message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Fermer", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: msgPar, style: .default, handler: { action in
            
            if let url = URL(string: urlPar){
                
                URLSession.shared.dataTask(with: url) { (Mdata, res, err) in
                    
                    guard let Mdata = Mdata , err == nil else
                    {
                        self.alertPrint(TitleController: "Une erreure est survenue", MsgController: "Relancer l'application", Titlealt: "OK", TableView: TableView)
                        return
                    }
                    
                   
                    if let d = String(data: Mdata, encoding: String.Encoding.utf8){
                        
                        
                            self.alertPrint(TitleController: "Vous avez \(optmsg) votre position", MsgController: "position \(optmsg)", Titlealt: "OK", TableView: TableView)
                        
                       
                        
                    } else{
                        
                        self.alertPrint(TitleController: "Une erreure est survenue", MsgController: "Relancer l'application", Titlealt: "OK", TableView: TableView)
                        
                    }
                    
                    }.resume()
            }
            
        }))
    
        alert.addAction(UIAlertAction(title: "Supprimer cet ami", style: .default, handler: { action in
            
            if let url = URL(string: urlDelete){
                
                URLSession.shared.dataTask(with: url) { (Mdata, res, err) in
                
                    guard let Mdata = Mdata , err == nil else
                    {
                        self.alertPrint(TitleController: "Une erreure est survenue", MsgController: "Relancer l'application", Titlealt: "OK", TableView: TableView)
                        return
                    }
                
                    if let d = String(data: Mdata, encoding: String.Encoding.utf8){
                    
                        
                            self.alertPrint(TitleController: "Vous avez supprimé un amis", MsgController: "Amis supprimé", Titlealt: "OK", TableView: TableView)
                        
                        
                                            
                    } else{
                    
                        self.alertPrint(TitleController: "Une erreure est survenue", MsgController: "Relancer l'application", Titlealt: "OK", TableView: TableView)
                    
                    }
                
                }.resume()
            }
        
        }))
    
        TableView.present(alert, animated: true, completion: nil)
    
}
    
    
}


class ItemTableAmis : NSObject{
    var id = String()
    var nb = String()
    var nom = String()
    var img = UIImage()
    var par = String()
}
