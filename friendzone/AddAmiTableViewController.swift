//
//  AddAmiTableViewController.swift
//  friendzone
//
//  Created by Julien on 06/03/2017.
//  Copyright © 2017 julien. All rights reserved.
//

import UIKit

class AddAmiTableViewController: UITableViewController, DataBaseDelegateTableAmis {

    var config = Config()
    var connect_id = ""
    
   
    
    var data = DataBaseTableAmis.shared
    
    
    func didLoadURLContact(code : Bool)
    {
        
        
        data.startRequeteGetURLContact()
        
        if (code)
        {
            self.alertPrint(TitleController: "Vous avez ajouté un amis", MsgController: "Amis ajouté", Titlealt: "OK")
        }
        else
        {
            self.alertPrint(TitleController: "Une erreure est survenue", MsgController: "Relancer l'application", Titlealt: "OK")
        }
        
        
        
    }
    
    func dataLoaded()
    {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        data.delegate = self
        data.startRequeteGetURLContact()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.listC.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tblView", for: indexPath)
        
        cell.textLabel?.text = data.listC[indexPath.row].nom
        cell.detailTextLabel?.text = data.listC[indexPath.row].nb
        cell.imageView?.image = data.listC[ indexPath.row].img
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let name = self.config.defaults.string(forKey: "name")
        {
            connect_id = name
        }
        let nom = data.listC[indexPath.row].nom
        let nb = data.listC[indexPath.row].id
        
        let url = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php?fichier=users&action=add_friend&values[id_amis]=\(nb)&values[id_co]=\(connect_id )"
        
        alertPrintRet(TitleController: "Ajouter \(nom) en ami ?",MsgController: "Ajouter en ami ?", Url: url , TableView: self)
        
    }
    
    
    func alertPrint(TitleController: String,MsgController: String, Titlealt: String) -> Void {
        let alert = UIAlertController(title: TitleController, message: MsgController,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Titlealt, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertPrintRet(TitleController: String,MsgController: String, Url: String ,TableView: UITableViewController) -> Void {
        
        let alert = UIAlertController(title: TitleController, message: MsgController,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Non", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { action in
            
            if let url = URL(string: Url){
                
                URLSession.shared.dataTask(with: url) { (Mdata, res, err) in
                    
                    guard let Mdata = Mdata , err == nil else
                    {
                        self.data.delegate?.didLoadURLContact(code: false)
                        return
                    }
                    
                    if let d = String(data: Mdata, encoding: String.Encoding.utf8){
                        
                        if d.contains("ok"){
                            self.data.delegate?.didLoadURLContact(code: true)
                        }else{
                            self.data.delegate?.didLoadURLContact(code: false)
                        }
                        
                    } else{
                        
                        self.data.delegate?.didLoadURLContact(code: false)
                        
                    }
                    
                    }.resume()
            }
            
        }))
        
        TableView.present(alert, animated: true, completion: nil)
        
    }
    

}
