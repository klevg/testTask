//
//  Request.swift
//  testTask
//
//  Created by Евгений Клебан on 3/5/19.
//  Copyright © 2019 Евгений Клебан. All rights reserved.
//

import Foundation

protocol ResultDelegate: class {
    func updateResultTableView()
}

class Request: URLSessionDataTask, URLSessionDelegate {
    
    let inputForSearch: String
    var items: [Item?]
    weak var delegate: ResultDelegate?
   
    init(input forSearch: String) {
        self.inputForSearch = forSearch
        self.items = []
        super.init()
        getSearchResult(for: forSearch)
    }
    
    
    func getSearchResult(for inputForSearch: String) {
        self.getResultJSON(inputString: inputForSearch) { (result, error) in
            DispatchQueue.global(qos: .userInteractive).async {
                guard let result = result else { print("error"); return }
                if let data = result.data(using: .utf8) {
                    
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if json == nil {
                        return
                    }
                    
                    let jsonArrayAny = json as? Dictionary<String, Any>
                    if jsonArrayAny == nil {
                        return
                    }

                    if let jsonArray = jsonArrayAny!["items"] as? [Dictionary<String, Any>] {
                        var returnArray: [Item] = []
                        for dict in jsonArray {
                            let newArray = Item(dictionary: dict)
                            print(newArray.link)
                            print(newArray.title)
                            returnArray.append(newArray)
                        }
                        self.items = returnArray
                        DispatchQueue.main.async {
                            self.delegate?.updateResultTableView()

                        }
                        
                    }
                }
            }
        }
        
    }
    
    func getResultJSON(inputString: String, completionHandler: @escaping (String?, Error?) -> Void) {
        let apiKey = "AIzaSyBaiPxS6zcM6b02-IxeTmu4vkesUv26tn0"
        let bundleId = "com.klevg.testTask"
        let searchEngineId = "013963759840762655514:yzet_vnh9ge"
        let serverAddress = String(format: "https://www.googleapis.com/customsearch/v1?q=%@&cx=%@&key=%@", inputString, searchEngineId, apiKey)
        
        
        let url = serverAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let finalUrl = URL(string: url!)
        let request = NSMutableURLRequest(url: finalUrl!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.setValue(bundleId, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let session = URLSession.shared
            
            let datatask = session.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                if let error = error {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
                
                if let data = data {
                    if let dataString = String(data: data, encoding: String.Encoding.utf8) {
                        DispatchQueue.main.async {
                            completionHandler(dataString, nil)
                        }
                    }
                }
            }
            datatask.resume()
        }
    }
    
}
