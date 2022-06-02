//
//  rsa.swift
//
//
//  Created by Tomasz on 04/08/2021.
//

import Foundation

@available(iOS 14.0, *)
func genKeysPair() -> Result<[String: String], Error> {
    let publicKeyAttr: [NSObject: NSObject] = [
                kSecAttrIsPermanent:true as NSObject,
                kSecClass: kSecClassKey, // added this value
                kSecReturnData: kCFBooleanTrue] // added this value
    let privateKeyAttr: [NSObject: NSObject] = [
                kSecAttrIsPermanent:true as NSObject,
                kSecClass: kSecClassKey, // added this value
                kSecReturnData: kCFBooleanTrue] // added this value
    var keyPairAttr = [NSObject: NSObject]()
    keyPairAttr[kSecAttrKeyType] = kSecAttrKeyTypeRSA
    keyPairAttr[kSecAttrKeySizeInBits] = 2048 as NSObject
    keyPairAttr[kSecPublicKeyAttrs] = publicKeyAttr as NSObject
    keyPairAttr[kSecPrivateKeyAttrs] = privateKeyAttr as NSObject
    var publicKey : SecKey?
    var privateKey : SecKey?;
    let statusCode = SecKeyGeneratePair(keyPairAttr as CFDictionary, &publicKey, &privateKey)

    if statusCode == noErr && publicKey != nil && privateKey != nil {
        var resultPublicKey: AnyObject?
        var resultPrivateKey: AnyObject?
        
        let statusPublicKey = SecItemCopyMatching(publicKeyAttr as CFDictionary, &resultPublicKey)
        let statusPrivateKey = SecItemCopyMatching(privateKeyAttr as CFDictionary, &resultPrivateKey)
        
        var response: [String: String] = [:]
        
        if statusPublicKey == noErr {
            if let publicKey = resultPublicKey as? Data {
                response.updateValue(publicKey.base64EncodedString(), forKey: "publicKey")
            } else {
                return .failure(SocialifyClient.SdkError.RSAPublicKeyToStringError)
            }
        } else {
            return .failure(SocialifyClient.SdkError.RSAPublicKeyToStringError)
        }
        
        if statusPrivateKey == noErr {
            if let privateKey = resultPrivateKey as? Data {
                response.updateValue(privateKey.base64EncodedString(), forKey: "privateKey")
            } else {
                return .failure(SocialifyClient.SdkError.RSAPrivateKeyToStringError)
            }
        } else {
            return .failure(SocialifyClient.SdkError.RSAPrivateKeyToStringError)
        }
        
        print("Key pair generated OK")
        
        return .success(response)
    } else {
        print("Error generating key pair: \(statusCode)")
        return .failure(SocialifyClient.SdkError.RSAKeyGenerationError)
    }
}
