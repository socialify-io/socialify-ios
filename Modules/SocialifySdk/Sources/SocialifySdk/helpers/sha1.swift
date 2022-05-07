//
//  sha1.swift
//
//
//  Created by Tomasz on 04/08/2021.
//

import Foundation
import CryptoKit

public extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
