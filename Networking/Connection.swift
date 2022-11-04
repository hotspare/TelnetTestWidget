//
//  Connection.swift
//  MuBounce
//
//  Created by J. Cheng on 11/4/19.
//

import Foundation
import Network

protocol ConnectionDelegate {
    func receive(data: Data)
    func stop()
}

class Connection {
    
    private static var nextID: Int = 0
    let nwConnection: NWConnection
    let id: Int
    
    var delegate:ConnectionDelegate?
    var state:NWConnection.State = .setup
        
    var buffer:[UInt8] = []
    var bufferWaitTimer:Timer? = nil
    
    required init(nwConnection: NWConnection) {
        self.nwConnection = nwConnection
        self.id = Connection.nextID
        Connection.nextID += 1
    }
    
    func start() {
        print("Connection \(self.id) will start")
        nwConnection.stateUpdateHandler = stateDidChange
        setupReceive()
        nwConnection.start(queue: .main)
    }
    
    func send(_ string:String) {
        let command = "\(string)\n"
        send(data: Data(command.utf8))
    }
    
    func send(data: Data) {
        nwConnection.send(content: data, completion: .contentProcessed( { [weak self] error in
            guard let strongSelf = self else {
                return
            }
            if let error = error {
                strongSelf.connectionDidFail(error: error)
                return
            }
        }))
    }
   
    func receiveData(_ data:Data) {
        delegate?.receive(data: data)
    }
    
    func stop() {
        print("Connection \(self.id) will stop")
    }
    
    func stateDidChange(to state: NWConnection.State) {
        self.state = state
        switch state {
        case .setup:
            break
        case .waiting(let error):
            connectionDidFail(error: error)
        case .preparing:
            break
        case .ready:
            print("Connection \(self.id) is ready")
        case .failed(let error):
            connectionDidFail(error: error)
        case .cancelled:
            break
        default:
            break
        }
    }
    
    func connectionDidFail(error: Error) {
        print("Connection \(self.id) did fail, error: \(error)")
        stop(error: error)
    }
    
    func connectionDidEnd() {
        print("Connection \(self.id) did end")
        stop(error: nil)
    }
    
    private func stop(error: Error?) {
        nwConnection.stateUpdateHandler = nil
        nwConnection.cancel()
        
        self.delegate?.stop()
        self.delegate = nil

        self.state = .cancelled
    }
    
    func setupReceive() {
        nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] (data, _, isComplete, error) in
            
            guard let strongSelf = self else {
                return
            }
            
            if let data = data, !data.isEmpty {
                strongSelf.receiveData(data)
            }
            if isComplete {
                strongSelf.connectionDidEnd()
            } else if let error = error {
                strongSelf.connectionDidFail(error: error)
            } else {
                strongSelf.setupReceive()
            }
            
        }
    }
}

