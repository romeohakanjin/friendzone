//
//  ListeAmisTableViewController.swift
//  friendzone
//
//  Created by Julien on 06/03/2017.
//  Copyright © 2017 julien. All rights reserved.
//

import UIKit

class ListeAmisTableViewController: UITableViewController, DataBaseDelegateTableAmis {

    
    var config = Config()
    var connect_id = ""
    
    var data = DataBaseTableAmis.shared
    
    
    func didLoadURLAmis(code : Bool,type: Bool)
    {
        
        data.startRequeteGetURLAmis()
        
        if(type){
            if (code)
            {
                self.alertPrint(TitleController: "Vous avez supprimé un amis", MsgController: "Amis supprimé", Titlealt: "OK")
            }
            else
            {
                self.alertPrint(TitleController: "Une erreure est survenue", MsgController: "Relancer l'application", Titlealt: "OK")
            }
        }else{
            if (code)
            {
                self.alertPrint(TitleController: "Vous avez partagé votre position à un amis", MsgController: "Position partagé", Titlealt: "OK")
            }
            else
            {
                self.alertPrint(TitleController: "Une erreure est survenue", MsgController: "Relancer l'application", Titlealt: "OK")
            }
            
        }
        
        
        
    }
    
    func dataLoaded()
    {
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        data.delegate = self
        data.startRequeteGetURLAmis()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        data.delegate = self
        data.startRequeteGetURLAmis()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return data.listA.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tblAmis", for: indexPath)
        
        cell.textLabel?.text = data.listA[indexPath.row].nom
        cell.detailTextLabel?.text = data.listA[indexPath.row].nb
        cell.imageView?.image = data.listA[ indexPath.row].img
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       
        let nom = data.listA[indexPath.row].nom
        let nb = data.listA[indexPath.row].id
        let par = data.listA[indexPath.row].par
        
        
        alertPrintAmis(Par: par, IDAMI: nb)
        
    }
    
    
    func alertPrint(TitleController: String,MsgController: String, Titlealt: String) -> Void {
        let alert = UIAlertController(title: TitleController, message: MsgController,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Titlealt, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertPrintAmis(Par: String, IDAMI: String) -> Void {
        
        if let name = self.config.defaults.string(forKey: "name")
        {
            connect_id = name
        }
        
        let TitleController = "Que souhaitez-vous faire ?"
        var msgPar = ""
        var urlPar = ""
        var optmsg = ""
        
        if Par == "0"{
            msgPar = "Partager ma position"
            
            urlPar = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php?fichier=users&action=partage_position&values[id_user]=\(connect_id)&values[id_ami]=\(IDAMI)&values[partage_pos]=1"
        }else{
            msgPar = "Supprimer ma position"
            
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
                        self.didLoadURLAmis(code : false,type: false)
                        return
                    }
                    
                    
                    if String(data: Mdata, encoding: String.Encoding.utf8) != nil{
                        
                        
                        self.didLoadURLAmis(code : true,type: false)
                        
                        
                        
                    } else{
                        
                        self.didLoadURLAmis(code : false,type: false)
                        
                    }
                    
                    }.resume()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Supprimer cet ami", style: .default, handler: { action in
            
            if let url = URL(string: urlDelete){
                
                URLSession.shared.dataTask(with: url) { (Mdata, res, err) in
                    
                    guard let Mdata = Mdata , err == nil else
                    {
                        self.didLoadURLAmis(code : false,type: false)
                        return
                    }
                    
                    if String(data: Mdata, encoding: String.Encoding.utf8) != nil{
                        
                        
                        self.didLoadURLAmis(code : true,type: true)
                        
                        
                        
                    } else{
                        
                        self.didLoadURLAmis(code : false,type: false)
                        
                    }
                    
                    }.resume()
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }}
