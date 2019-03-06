//
//  ViewController.swift
//  testTask
//
//  Created by Евгений Клебан on 3/5/19.
//  Copyright © 2019 Евгений Клебан. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ResultDelegate {
    
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    private var request: Request? = nil
    
    
    @IBAction func searchButtonIsPressed(_ sender: UIButton) {
        if sender.currentTitle == "Google Search" {
            startSearch(input: textField)
        } else if sender.currentTitle == "Stop" {
            sender.setTitle("Google Search", for: [])
        }
    }
    
    private func startSearch(input forSearch: UITextField) {
        searchButton.setTitle("Stop", for: [])
        
        if let input = forSearch.text {
            let inputWithoutWhitespaces = input.trimmingCharacters(in: .whitespacesAndNewlines)
            if !inputWithoutWhitespaces.isEmpty {
                request = Request(input: inputWithoutWhitespaces)
                request?.delegate = self
            }
        }
    }

    func updateResultTableView() {
            self.resultTableView.reloadData()
    }


    
    
    
     override func viewDidLoad() {
        super.viewDidLoad()
        resultTableView.dataSource = self
        resultTableView.delegate = self
        textField.delegate = self
        
    }
    
  
}




// MARK: Table View Data Source
extension ViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return request?.items.count ?? 0
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ResultTableViewCell  else { fatalError() }
        
        let link = request?.items[indexPath.row]?.link ?? ""
        let title = request?.items[indexPath.row]?.title ?? ""
        
        cell.link.text =  link
        cell.title.text = title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}


// MARK: Text Field Delegate
extension ViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
