//
//  NexmoSMS.swift
//  NexmoTest
//
//  Created by Nicholas Allio on 17/03/2017.
//  Copyright © 2017 Nicholas Allio. All rights reserved.
//

import UIKit

public class NexmoSMS: NSObject {
    private let baseURL = "https://rest.nexmo.com/sms/json"
    private let apiKey = "4b2ed2ad"
    private let apiSecret = ""
    private let sender = "NicholasTestApp"
    
    private let session = URLSession.shared
    
    public func sendSMS(to: String, result: @escaping (Int?, Error?)->()) {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let messageData = buildJSONwithParameters(to: to, withText: "Here is your message") {
            request.httpBody = messageData
        } else {
            print("Error creating body")
            result(-1, nil)
        }
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard (error == nil) else {
                result(nil, error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                result(nil, error)
                return
            }
            
            guard let data = data else {
                result(nil, error)
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                    if let messages = jsonResponse["messages"] as? [[String:Any]] {
                        if let message = messages.first {
                            if let responseStatus = message["status"] as? String, Int(responseStatus) == 0 {
                                result(Int(responseStatus), nil)
                            } else {
                                result(-1, error)
                            }
                        } else {
                            result(-1, error)
                        }
                    } else {
                        result(-1, error)
                    }
                } else {
                    result(-1, error)
                }
                
            } catch {
                print("Error data json")
            }
        }
        
        dataTask.resume()
        
    }
    
    private func buildJSONwithParameters(to: String, withText text: String) -> Data? {
        let sanitizedNumber = to.replacingOccurrences(of: "+", with: "")
        let toNumber = sanitizedNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        let rawJSON: [String:Any] = ["api_key": apiKey,
                                     "api_secret": apiSecret,
                                     "to": toNumber,
                                     "from": sender,
                                     "text": text
                                    ]
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: rawJSON, options: .prettyPrinted)
            return bodyData
        } catch {
            print("Error occurred")
            return nil
        }
    }

}
