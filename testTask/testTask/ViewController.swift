//
//  ViewController.swift
//  testTask
//
//  Created by Евгений Клебан on 3/5/19.
//  Copyright © 2019 Евгений Клебан. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var resultTableView: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    
    
    
     override func viewDidLoad() {
        super.viewDidLoad()
        resultTableView.dataSource = self
        resultTableView.delegate = self
        //getResultJSON(for: "hello, world!")
    }
    
    
    
    
    
    func getResultJSON(for inputForSearch: String) {
        let apiKey = ""
        let bundleId = ""
        let searchEngineId = ""
        let serverAddress = String(format: "https://www.googleapis.com/customsearch/v1?q=%@&cx=%@&key=%@", inputForSearch, searchEngineId, apiKey)
        
        
        let url = serverAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let finalUrl = URL(string: url!)
        let request = NSMutableURLRequest(url: finalUrl!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.setValue(bundleId, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let session = URLSession.shared
            
            let datatask = session.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        print("asyncResult\(jsonResult)")
                    }
                }
                    
                catch let error as NSError{
                    print(error.localizedDescription)
                }
            }
            
            datatask.resume()
        }
    }
    
}



// MARK: Table View Data Source
extension ViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ResultTableViewCell  else { fatalError() }
        cell.link.text = "Link"
        cell.title.text = "Title"
        
        return cell
    
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }


}
