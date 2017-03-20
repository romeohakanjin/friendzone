import UIKit
import Contacts

protocol DataBaseDelegateTableAmis
{
    func dataLoaded()
    func didLoadURLContact( code : Bool)
    func didLoadURLAmis(code : Bool,type: Bool)
}

extension DataBaseDelegateTableAmis
{
    func dataLoaded(){}
    func didLoadURLContact(code : Bool){}
    func didLoadURLAmis(code : Bool,type: Bool){}
}



class DataBaseTableAmis: NSObject {
    
    static let shared = DataBaseTableAmis()
    var delegate : DataBaseDelegateTableAmis?
    var listC = [ItemTableContact]()
    var listA = [ItemTableAmis]()
    
    var config = Config()
    var url = ""
    var id_co = ""
    
    
    
    //getAllContacts ->didLoadContacts
    //addFriend/SharePosition ->didSharePosition
    public func startRequeteGetURLContact()
    {
        
        if let name = self.config.defaults.string(forKey: "name")
        {
            id_co = name
        }
        
        let store = CNContactStore()
        var requete = String()
        self.listC.removeAll()
        self.listA.removeAll()
        
        store.requestAccess(for: .contacts, completionHandler: {
            
            granted, error in guard granted else {
                return
            }
            
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
            var cnContacts = [CNContact]()
            
            
            
            do {
                
                try store.enumerateContacts(with: request){ (contact, cursor) -> Void in
                    cnContacts.append(contact)
                }
                
            } catch let error {
                print("Fetch contact error: \(error)")
            }
            
            for contact in cnContacts {
                let nb = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
                requete += "&values[array][]=\(nb)"
            }
            
            
            
            let url = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php?fichier=users&action=non_friend&\(requete)&values[id_user]=\(self.id_co)"
            
            
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
                                    
                                    
                                    let i = ItemTableContact()
                                    
                                    let imageName = "imgdefault.png"
                                    i.img = UIImage(named: imageName)!
                                    

                                    
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
                                        
                                        store.requestAccess(for: .contacts, completionHandler: {
                                            granted, error in guard granted else {
                                                
                                                return
                                                
                                            }
                                            
                                            
                                            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactImageDataAvailableKey] as [Any]
                                            let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
                                            var cnContacts = [CNContact]()
                                            
                                            do {
                                                
                                                try store.enumerateContacts(with: request){ (contact, cursor) -> Void in
                                                    cnContacts.append(contact)
                                                }
                                                
                                            } catch let error {
                                                print("Fetch contact error: \(error)")
                                            }
                                            
                                            for contact in cnContacts {
                                                
                                                let nb = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
                                                
                                                
                                                if nb == item as! String {
                                                    
                                                    
                                                    if contact.imageDataAvailable {
                                                        i.img = UIImage(data: contact.imageData!)!
                                                        DispatchQueue.main.async(execute:{
                                                            
                                                            self.delegate?.dataLoaded()
                                                            
                                                        })
                                                    }
                                                    
                                                    break
                                                    
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
                                    
                                    self.listC.append(i)
                                    
                                }
                                
                                
                            }
                        }
                        
                    }catch{
                       self.startRequeteGetURLContact()
                    }
                    
                    DispatchQueue.main.async(execute:{
                        self.delegate?.dataLoaded()
                    })
                    }.resume()
            }
        })
    }
    
    
    
    
    
    func startRequeteGetURLAmis()
    {
        if let name = self.config.defaults.string(forKey: "name")
        {
            id_co = name
        }
        
        let store = CNContactStore()
        self.listA.removeAll()
        self.listC.removeAll()
        
        let url = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php/?fichier=users&action=amis_liste&values[id]=\(self.id_co)"
        
        if let url = URL(string: url){
            
            URLSession.shared.dataTask(with: url) { (Mdata, res, err) in
                
                guard let Mdata = Mdata , err == nil else {
                    return
                }
                
                do{
                    
                    let json = try JSONSerialization.jsonObject(with: Mdata, options: .allowFragments)
                    
                    if let root = json as? [String : AnyObject]{
                        if let feed = root["result"] as? [[String : AnyObject]]{
                            
                            for item in feed {
                                
                                let i = ItemTableAmis()
                                
                                let imageName = "imgdefault.png"
                                i.img = UIImage(named: imageName)!
                                

                                
                                if let item = item["nom_user"]
                                {
                                    i.nom = item as! String
                                    print(i.nom)
                                }
                                else
                                {
                                    print("Other")
                                }
                                
                                if let item = item["tel"]
                                {
                                    i.nb = item as! String
                                    
                                    store.requestAccess(for: .contacts, completionHandler: {
                                        granted, error in guard granted else {
                                            
                                            return
                                            
                                        }
                                        
                                        
                                        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey,CNContactImageDataKey,CNContactImageDataAvailableKey] as [Any]
                                        let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
                                        var cnContacts = [CNContact]()
                                        
                                        do {
                                            
                                            try store.enumerateContacts(with: request){ (contact, cursor) -> Void in
                                                cnContacts.append(contact)
                                            }
                                            
                                        } catch let error {
                                            print("Fetch contact error: \(error)")
                                        }
                                        
                                        for contact in cnContacts {
                                            
                                            let nb = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
                                            
                                            if nb == item as! String {
                                                
                                                
                                                if contact.imageDataAvailable {
                                                    i.img = UIImage(data: contact.imageData!)!
                                                    DispatchQueue.main.async(execute:{
                                                        
                                                        self.delegate?.dataLoaded()
                                                        
                                                    })
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
                                
                                self.listA.append(i)
                                
                            }
                            
                            
                        }
                    }
                    
                }catch{
                    self.startRequeteGetURLAmis()
                }
                
                DispatchQueue.main.async(execute:{
                    self.delegate?.dataLoaded()
                })
                
                }.resume()
        }
    }
    
    
    
    
    
    
    
}





///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////





class ItemTableContact : NSObject{
    var id = String()
    var nb = String()
    var nom = String()
    var img = UIImage()
}

class ItemTableAmis : NSObject{
    var id = String()
    var nb = String()
    var nom = String()
    var img = UIImage()
    var par = String()
}
