//
//  ViewController.swift
//  testTask
//
//  Created by Евгений Клебан on 3/5/19.
//  Copyright © 2019 Евгений Клебан. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ResultDelegate, LimitOfRequestDelegate, updateProgressViewDelegate {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    private var request: Request? = nil
    
    
    private var searchDidEndObserver: NSObjectProtocol?
    private var searchShouldEndObserver: NSObjectProtocol?
    private var errorInRequestObserver: NSObjectProtocol?
    
    @IBAction func searchButtonIsPressed(_ sender: UIButton) {
        if sender.currentTitle == "Google Search" {
            startSearch(input: textField)
        } else if sender.currentTitle == "Stop" {
            NotificationCenter.default.post(name: .SearchShouldEnd, object: nil)
            sender.setTitle("Google Search", for: [])
        }
    }
    
    private func startSearch(input forSearch: UITextField) {
        searchButton.setTitle("Stop", for: [])
        
        if let input = forSearch.text {
            let inputWithoutWhitespaces = input.trimmingCharacters(in: .whitespacesAndNewlines)
            if !inputWithoutWhitespaces.isEmpty {
                request = Request(input: inputWithoutWhitespaces)
                request?.resultDelegate = self
                request?.limitDelegate = self
                request?.updateProgressViewdelegate = self
            } else {
                presentAlertIfBadInput()
                NotificationCenter.default.post(name: .SearchDidEnd, object: nil)
            }
        } else {
            presentAlertIfBadInput()
            NotificationCenter.default.post(name: .SearchDidEnd, object: nil)
        }
    }

    func updateResultTableView() {
            self.resultTableView.reloadData()
    }
    
    func updateProgressView(_ value: Float) {
        self.progressView.progress = value
    }
    
    func showAlertWithOutOfLimit() {
        let alert = UIAlertController(
            title: "Search failed",
            message: "The limit of requests per day has been exhausted",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        present(alert, animated: true)
        
    }
    
    private func presentAlertIfBadInput() {
        let alert = UIAlertController(
            title: "Search failed",
            message: "Bad input",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        present(alert, animated: true)
        
    }
    
    private func presentAlertWithError(error: Error) {
        let alert = UIAlertController(
            title: "Search failed",
            message: "\(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        present(alert, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultTableView.dataSource = self
        resultTableView.delegate = self
        textField.delegate = self
        
        searchDidEndObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("SearchDidEnd"),
            object: nil,
            queue: OperationQueue.main,
            using: { notification in self.searchButton.setTitle("Google Search", for: []) }
        )
        
        searchShouldEndObserver = NotificationCenter.default.addObserver(
            forName: .SearchShouldEnd,
            object: nil,
            queue: OperationQueue.main,
            using: { notification in self.resultTableView.reloadData() }
        )
        
        errorInRequestObserver = NotificationCenter.default.addObserver(
            forName: .ErrorInRequestIsHappened,
            object: nil,
            queue: nil,
            using: { notification in
                if let error = notification.userInfo?.values.first as? Error {
                    self.presentAlertWithError(error: error)
                } else {
                    print("Can't read the error")
                } }
        )
        
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        self.textField.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonAction() {
        textField.resignFirstResponder()
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
        startSearch(input: textField)
        return true
    }
}


extension Notification.Name {
    static let SearchDidEnd = Notification.Name("SearchDidEnd")
    static let SearchShouldEnd = Notification.Name("SearchShouldEnd")
    static let ErrorInRequestIsHappened = Notification.Name("ErrorInRequestIsHappened")
}

