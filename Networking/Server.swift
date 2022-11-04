//
//  Server.swift
//  MuBounce
//
//  Created by J. Cheng on 11/4/19.
//

import Foundation
import Network

class Server {
    
    let listener: NWListener
    let port: NWEndpoint.Port
    let connectionClass: Connection.Type
    
    var connectionsByID: [Int:Connection] = [:]
    
    init(port:NWEndpoint.Port, connectionClass: Connection.Type = Connection.self) {
        self.port = port
        self.connectionClass = connectionClass
        self.listener = try! NWListener(using: .tcp, on: port)
    }
    
    func start() throws {
        print("Server starting on port \(port)...")
        listener.stateUpdateHandler = stateDidChange
        listener.newConnectionHandler = didAccept
        listener.start(queue: .global(qos: .default))
    }
    
    func stateDidChange(to newState: NWListener.State) {
        switch newState {
        case .setup:
            break
        case .waiting:
            break
        case .ready:
            print("Server on port \(port) is ready.")
            break
        case .failed(let error):
            print("Server on port \(port) failed: \(error)")
            self.stop()
        case .cancelled:
            break
        default:
            break
        }
    }
    
    private func didAccept(nwConnection: NWConnection) {
        let connection = connectionClass.init(nwConnection: nwConnection)
        self.connectionsByID[connection.id] = connection
  
        DispatchQueue.main.sync {
            connection.start()
            if case let .hostPort(host, _ /* remote port */) = nwConnection.endpoint {
                print("Server did open connection \(connection.id) from \(host)")
            }
            else {
                print("ERROR: Server accepted an unexpected connection!")
            }
            NotificationCenter.default.post(name: .serverHasConnection, object: connection)
        }
        
    }
    
    private func connectionDidStop(_ connection: Connection) {
        self.connectionsByID.removeValue(forKey: connection.id)
        print("Server did close connection \(connection.id)")
        if self.connectionsByID.isEmpty {
            NotificationCenter.default.post(name: .serverHasNoConnections, object: nil)
        }
    }
    
    private func stop() {
        self.listener.stateUpdateHandler = nil
        self.listener.newConnectionHandler = nil
        self.listener.cancel()
        for connection in self.connectionsByID.values {
            connection.stop()
        }
        self.connectionsByID.removeAll()
        print("Server on port \(port) is stopped.")
    }
}
