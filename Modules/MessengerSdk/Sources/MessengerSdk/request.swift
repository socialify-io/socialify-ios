//
//  request.swift
//  
//
//  Created by Tomasz on 19/05/2021.
//

import Foundation
import Combine
import SwiftSoup

extension MessengerClient {
    func _request(request: URLRequest, completion: @escaping (Result<Data, ConnectionError>) -> Void) {
        var request = request
        request.addValue("Socialify - MessengerSdk \(LIBRARY_VERSION)", forHTTPHeaderField: "User-Agent")
        session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                  if let error = error {
                    completion(.failure(ConnectionError.wyjebaloSieWPizdu))
                    return
                  }

                completion(.failure(ConnectionError.wyjebaloSieWPizdu))
                return
                }
            
            do {
                completion(.success(data))
                return
            } catch {
                completion(.failure(ConnectionError.wyjebaloSieWPizdu))
            }
            
        }.resume()
    }
}
