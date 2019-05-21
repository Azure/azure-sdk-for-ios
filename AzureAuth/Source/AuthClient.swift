//
//  AuthClient.swift
//  AzureAuth
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCore

class AuthClient {
    
    static let shared: AuthClient = AuthClient()

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    var session: URLSession!
    
    
    var user: AuthUser? {
        didSet {
            if user != nil {
                try? Keychain.saveDataToKeychain(encoder.encode(user!), withKey: "authuser")
            }
        }
    }
    
    
    fileprivate init(configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        
        configuration.httpAdditionalHeaders = Bundle(for: AuthClient.self).defaultHttpHeaders
        
        session = URLSession(configuration: configuration)
        
        if let keyData = try? Keychain.getDataFromKeychain(forKey: "authuser"),
            let authUser = try? decoder.decode(AuthUser.self, from: keyData) {
            user = authUser
        }
    }
    
    
    func authHeader() throws -> (key:String, value:String) {
        
        guard let token = user?.authenticationToken else { throw AuthClientError.noCurrentUser }
        
        return ("X-ZUMO-AUTH", token)
    }
    
    
    func login(to service: URL, with provider: IdentityProvider, completion: @escaping (Response<AuthUser>) -> Void) {
        
        var request = URLRequest(url: service.appendingPathComponent(provider.tokenPath))
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try provider.payload()
        } catch {
            print(error)
            completion(Response(AuthClientError.invalidToken)); return;
        }
        
        return send(request, completion: completion)
    }
    
    
    func refresh(for service: URL, completion: @escaping (Response<AuthUser>) -> Void) {
        
        var request = URLRequest(url: service.appendingPathComponent(IdentityProvider.refreshPath))
        
        do {
            let header = try authHeader()
            request.addValue(header.value, forHTTPHeaderField: header.key)
        } catch {
            completion(Response(error)); return
        }
        
        return send(request, completion: completion)
    }
    
    
    fileprivate func send(_ request: URLRequest, completion: @escaping (Response<AuthUser>) -> Void) {
        
        session.dataTask(with: request) { (data, response, error) in
        
        let httpResponse = response as? HTTPURLResponse
        
            if let error = error {
        
                completion(Response(request: request, data: data, response: httpResponse, result: .failure(error)))
        
            } else if let data = data {
        
                //Log.debugMessage(String(data: data, encoding: .utf8) ?? "fail")
        
                do {
        
                    let authUser = try self.decoder.decode(AuthUser.self, from: data)
        
                    self.user = authUser
                    
                    completion(Response(request: request, data: data, response: httpResponse, result: .success(authUser)))
        
                } catch {
        
                    completion(Response(request: request, data: data, response: httpResponse, result: .failure(error)))
                }
            } else {
        
                completion(Response(request: request, data: data, response: httpResponse, result: .failure(AuthClientError.unknown)))
            }
        }.resume()
    }
}
