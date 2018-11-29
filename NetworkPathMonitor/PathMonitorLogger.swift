//
//  PathMonitorLogger.swift
//  PathMonitor
//
//  Created by Federico Cappelli on 26/11/2018.
//  Copyright © 2018 Mimecast Ltd. All rights reserved.
//

import UIKit
import Network

class PathMonitorLogger: NSObject {

    let pathMonitor = NWPathMonitor()
    let queue = DispatchQueue(label: "com.federicocappelli.PathMonitorLogger", qos: DispatchQoS.background)
    
    override init() {
        super.init()
        
        pathMonitor.pathUpdateHandler = { (path) in
            print("Network path changed: \(path.debugDescription)")
        }
        pathMonitor.start(queue: queue)
    }
    
    func logPath() -> Void {
        //Path
        let path = pathMonitor.currentPath
        let interfaces = path.availableInterfaces
        var statusSimbol = ""
        switch path.status {
        case .satisfied:
            statusSimbol = "✅"
        case .unsatisfied:
            statusSimbol = "⛔️"
        case .requiresConnection:
            statusSimbol = "⚠️🔌"
        }
        let statusString = "Status: \(statusSimbol)"
        let ipv4String = "IPV4: \(path.supportsIPv4 == true ? "✅" : "❌")"
        let ipv6String = "IPV6: \(path.supportsIPv6 == true ? "✅" : "❌")"
        let dnsString = "DNS: \(path.supportsDNS == true ? "✅" : "❌")"
        let expensiveString = "\(path.isExpensive == true ? "💵💵💵" : "💵")"
        
        //get used interface
        let currentInterface = interfaces.first { path.usesInterfaceType($0.type) }
        print("\(statusString) | \(ipv4String) | \(ipv6String) | \(dnsString) | \(expensiveString) - Current interface: \( currentInterface == nil ? "-" : currentInterface!.niceDescription())")
        
        //Interfaces
        let interfacesStrings = interfaces.map { $0.niceDescription() }
        print("Available interfaces: \(interfacesStrings)")
    }
}

fileprivate extension NWInterface {
    
    func niceDescription() -> String {
        return "\(self.name) : \(self.type) \(self.typeIcon())"
    }
    
    func typeIcon() -> String {
        switch self.type {
        case .cellular:
            return "📶"
        case .loopback:
            return "⥀"
        case .other:
            return "❓"
        case .wifi:
            return "📡"
        case .wiredEthernet:
            return "🔌"
        }
    }
}
