//
//  File.swift
//  
//
//  Created by Tomasz on 23/05/2022.
//

import Foundation
import CryptoKit

func generatePrivateKey() -> P256.KeyAgreement.PrivateKey {
    let privateKey = P256.KeyAgreement.PrivateKey()
    return privateKey
}

func deriveSymmetricKey(privateKey: P256.KeyAgreement.PrivateKey, publicKey: P256.KeyAgreement.PublicKey) throws -> SymmetricKey {
    let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
    
    let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
        using: SHA256.self,
        salt: Data(),
        sharedInfo: Data(),
        outputByteCount: 32
    )
    
    return symmetricKey
}

func encrypt(text: String, symmetricKey: SymmetricKey) throws -> AES.GCM.SealedBox {
    let textData = text.data(using: .utf8)!
    //let nonce: AES.GCM.Nonce = try AES.GCM.Nonce(data: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
    let encrypted = try AES.GCM.seal(textData, using: symmetricKey)
    return encrypted
}
