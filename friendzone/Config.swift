//
//  Config.swift
//  friendzone
//
//  Created by Romeo Hakanjin on 03/03/2017.
//  Copyright © 2017 Friend Zone Corporation. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class Config: NSObject {
	
	let url : String = "http://friendzone01.esy.es/php/friendzoneapi/api/api.php?fichier=users&"
    //let url : String = "http://friendzone.epizy.com/api/api.php?fichier=users&"

    let defaults = UserDefaults.standard
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }

    
}
