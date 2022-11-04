//
//  Notification+Name.swift
//  MuBounce
//
//  Created by J. Cheng on 11/4/19.
//

import Foundation

extension Notification.Name {
    
    static let domain = "MuBounce"

    static let debugMessage = Notification.Name("\(domain).debugMessage")
    static let serverHasConnection = Notification.Name("\(domain).serverHasConnection")
    static let serverHasNoConnections = Notification.Name("\(domain).serverHasNoConnections")
}
