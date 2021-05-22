import Foundation
import SwiftSoup

public class MessengerClient {
    
    public init() {}
    
    public let LIBRARY_VERSION = "v0.0.1"
    public let session = URLSession.shared
    
    public func login(email: String, password: String) {
        getParams(email: email, password: password) { response in
            do {
                let payload = try response.get()
                
                let url = URL(string: "https://www.messenger.com/login/password")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                request.httpBody = Data(payload.map { "\($0.key)=\($0.value)" }.joined(separator: "&").utf8)
                
                self._request(request: request) { response in
                    do {
                        let content: String = String(data: try response.get(), encoding: String.Encoding.utf8) ?? ""
                        print(content)
                       
                    } catch {
                        print("popsulo sie")
                    }
                }
            } catch {
                print("popsulo sie")
            }
        }
    }
    
    private func getParams(email: String, password: String, completion: @escaping (Result<[String: Any], ConnectionError>) -> Void) {
        let requiredInputs = ["jazoest", "lsd", "initial_request_id", "timezone", "lgnrnd", "lgnjs", "default_persistent"]
        
        var payload: [String: Any] = [
            "jazoest": "",
            "lsd": "",
            "initial_request_id": "",
            "timezone": "-120",
            "lgndim": "eyJ3IjoxNDQwLCJoIjo5MDAsImF3IjoxNDQwLCJhaCI6ODc1LCJjIjozMH0%3D",
            "lgnrnd": "",
            "lgnjs": "n",
            "email": email,
            "pass": password,
            "login": "1",
            "default_persistent": ""
        ]
        
        //var identifier: String = ""

        let url = URL(string: "https://www.messenger.com/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        _request(request: request) { data in
            do {
                let content: String = String(data: try data.get(), encoding: String.Encoding.utf8) ?? ""
                    
                let doc: Document = try SwiftSoup.parse(content)
                
                /*let regex = "\"identifier\":\"[a-z-0-9]{32}\""
                
                let identifierMatch = matches(for: regex, in: content)
                
                identifier = identifierMatch[0]
                    .replacingOccurrences(of: "\"identifier\":\"", with: "")
                    .replacingOccurrences(of: "\"", with: "")*/
                
                guard let inputs = try? doc.select("input") else {
                    completion(.failure(ConnectionError.parsowanieInputowSieWyjebalo))
                    return
                }
                
                try inputs.forEach { input in
                    if (requiredInputs.contains(try input.attr("name"))) {
                        payload[try input.attr("name")] = try input.attr("value")
                    }
                }
                
                completion(.success(payload))
                return
            } catch {
                completion(.failure(ConnectionError.wyjebaloSieWPizdu))
            }
        }
        
        /*let async_ssoUrl = URL(string: "https://www.facebook.com/login/async_sso/messenger_dot_com")!
        var async_ssoRequest = URLRequest(url: async_ssoUrl)
        async_ssoRequest.httpMethod = "POST"

        let async_ssoPayload: [String: Any] = [
            "identifier": identifier,
            "initial_request_id": payload["initial_request_id"] ?? "",
            "__user": 0,
            "__a": 1,
            "__dyn": "7xe6E5aU7ibwKBAo2vwAxu13wqovzEdEc8uwdK0lW4o3Bw5VCwjE3awbG0MU662y0umUS1vwhE3Ngao881FU3rw9O0RE2Jw8W0b1w",
            "__req": 1,
            "__be": -1,
            "__pc": "PHASED:messengerdotcom_pkg",
            "__re": 3716917,
            "lsd": payload["lsd"] ?? ""
        ]
        
        async_ssoRequest.httpBody = Data(async_ssoPayload.map { "\($0.key)=\($0.value)" }.joined(separator: "&").utf8)
        
        _request(request: async_ssoRequest) { data in
            do {
                let content: String = String(data: try data.get(), encoding: String.Encoding.utf8) ?? ""
                    
                print(content)
                return
            } catch {
                completion(.failure(ConnectionError.wyjebaloSieWPizdu))
            }
        }*/
    }
    
    enum ConnectionError: Error {
        case wyjebaloSieWPizdu
        case parsowanieInputowSieWyjebalo
    }
}
