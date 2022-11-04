//
//  Data+Util.swift
//  MuBounce
//
//  Created by J. Cheng on 11/4/22.
//

import Foundation

extension Data {
    
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
    
    init?(hexadecimal: String) {
        guard hexadecimal.count.isMultiple(of: 2) else {
            return nil
        }
        
        let chars = hexadecimal.map { $0 }
        let bytes = stride(from: 0, to: chars.count, by: 2)
            .map { String(chars[$0]) + String(chars[$0 + 1]) }
            .compactMap { UInt8($0, radix: 16) }
        
        guard hexadecimal.count / bytes.count == 2 else { return nil }
        self.init(bytes)
    }
    
}
