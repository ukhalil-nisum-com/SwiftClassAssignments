//
//  UrlDataService.swift
//  Assignment3
//
//  Created by NISUM on 7/6/17.
//  Copyright © 2017 Nisum Macbook. All rights reserved.
//

import Foundation

class UrlDataService {
    
    let serverURLBase = "http://localhost:3000/"
    
    func doURLRequest<T>(objectType:String, responseHandler:@escaping (T) -> Void)	{
        let requestURL: URL = URL(string: "\(serverURLBase)\(objectType)")!
        let urlRequest: URLRequest = URLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) -> Void in
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                if [Any]() is T {
                    let array = self.readJSONArray(data: data)
                    responseHandler(array as! T)
                }
            }
        }
        task.resume()
    }
    
    func readJSONArray(data:Data?) -> [Any]	{
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
            if let array = json as? [Any]    {
                for object in array {
                    if let jsonObject = object as? Dictionary<String, Any> {
                        if let stringValue = jsonObject["name"] as? String {
                            print("Name: \(stringValue)")
                        }
                    }
                    if let jsonArray = object as? [Any] {
                        print("nestedArray found: \(jsonArray.count)")
                    }
                }
                return array
            }
        } catch {
            print("Error with Json: \(error)")
        }
        return [Any]()
    }
}
