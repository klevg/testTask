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

protocol LimitOfRequestDelegate: class {
    func showAlertWithOutOfLimit()
}

protocol updateProgressViewDelegate: class {
    func updateProgressView(_ value: Float)
}

class Request: URLSessionDataTask, URLSessionDelegate, URLSessionDataDelegate {
    
    let inputForSearch: String
    var items: [Item?]
    weak var resultDelegate: ResultDelegate?
    weak var limitDelegate: LimitOfRequestDelegate? = nil
    weak var updateProgressViewdelegate: updateProgressViewDelegate? = nil
    private var searchShouldEndObserver: NSObjectProtocol?
   
    init(input forSearch: String) {
        self.inputForSearch = forSearch
        self.items = []
        super.init()
        getSearchResult(for: forSearch)
    }
    
    // for urlsession indication
    private var buffer: NSMutableData = NSMutableData()
    private var session: URLSession?
    private var dataTask: URLSessionDataTask?
    private var expectedContentLength = 0
    
    
    private func getSearchResult(for inputForSearch: String) {
        
        searchShouldEndObserver = NotificationCenter.default.addObserver(
            forName: .SearchShouldEnd,
            object: nil,
            queue: OperationQueue.main,
            using: { notification in self.items = [nil] }
        )
        
        getResultJSON(inputString: inputForSearch) { (result, error) in
            
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
                            self.resultDelegate?.updateResultTableView()

                        }
                        
                    } else {
                        // in this case, the limit of requests per day has been exhausted
                        if let jsonArray = jsonArrayAny!["error"] as? Dictionary<String, Any> {
                            if let codeOfError = jsonArray["code"] as? Int {
                                print("\(codeOfError) limit exhausted")
                                NotificationCenter.default.post(name: .SearchDidEnd, object: nil)
                                DispatchQueue.main.async {
                                    self.limitDelegate?.showAlertWithOutOfLimit()
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    private func getResultJSON(inputString: String, completionHandler: @escaping (String?, Error?) -> Void) {
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
            
            self.searchShouldEndObserver = NotificationCenter.default.addObserver(
                forName: .SearchShouldEnd,
                object: nil,
                queue: nil,
                using: { notification in
                    session.invalidateAndCancel()
                    print("datatask canceled!")
            } )
            
            let datatask = session.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                
                if let error = error {
                    let postedError: [String: Error] = [error.localizedDescription: error]
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                        NotificationCenter.default.post(name: .SearchDidEnd, object: nil)
                        NotificationCenter.default.post(name: .ErrorInRequestIsHappened, object: nil, userInfo: postedError)
                    
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

extension Request {
   
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        let percentageDownloaded = Float(buffer.length) / Float(expectedContentLength)
        self.updateProgressViewdelegate?.updateProgressView(percentageDownloaded)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
        expectedContentLength = Int(response.expectedContentLength)
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.updateProgressViewdelegate?.updateProgressView(1.0)
    }
}
