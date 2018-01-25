//
//  ViewController.swift
//  lab02
//
//  Created by Michal Kolbusz on 1/25/18.
//  Copyright © 2018 Michal Kolbusz. All rights reserved.
//

import UIKit
import Alamofire	
import DGElasticPullToRefresh

class ViewController: UIViewController, UITableViewDataSource {

    var messages: [NSDictionary] = []
    
    @IBOutlet var messagesTableView: UITableView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadData();
        
        // Initialize tableView
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        self.messagesTableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            self?.loadData();
            // Do not forget to call dg_stopLoading() at the end
            self?.messagesTableView.dg_stopLoading()
            }, loadingView: loadingView)
        self.messagesTableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        self.messagesTableView.dg_setPullToRefreshBackgroundColor(messagesTableView.backgroundColor!)
        
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.row]
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = message["name"] as? String
        cell.detailTextLabel?.text = message["message"] as? String
        
        return cell;
    }
    
    @IBAction func sendNewMessageBtn(_ sender: Any) {
        let alertController = UIAlertController(title: "New message", message: "Please state your name and message", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your name"
        } )
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Your message"
        } )
        
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { action in
            let name = alertController.textFields?[0].text
            let message = alertController.textFields?[1].text
            
            if ((name?.characters.count) != nil) && ((message?.characters.count) != nil) {
                Alamofire.request("https://home.agh.edu.pl/~ernst/shoutbox.php?secret=ams2017", method: HTTPMethod.post, parameters: ["name": name!, "message": message!]).responseJSON(completionHandler: { (response) in
                    if response.result.value is NSNull {
                        return
                    }
                    let json = response.result.value as? NSDictionary
                    print("\(json)")
                });
            }
            
        })
        alertController.addAction(sendAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: { _ in })
    }
    
    func loadData() {
        Alamofire.request("https://home.agh.edu.pl/~ernst/shoutbox.php?secret=ams2017").responseJSON { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Result: \(response.result)")
            
            if response.result.value is NSNull {
                return
            }
            
            let json = response.result.value as? NSDictionary
            let entries = json?["entries"] as? NSArray
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "Y-MM-dd HH:mm:ss"
            self.messages = [];
            for entry in entries! {
                let message = entry as? NSDictionary
                self.messages.append(message!)
            }
            self.messages = self.messages.sorted(by: {
                let date1 = dateFormatter.date(from: $0.value(forKey: "timestamp") as! String)
                let date2 = dateFormatter.date(from: $1.value(forKey: "timestamp") as! String)
                return date1! > date2!
            })
            
            self.messagesTableView.reloadData()
        
        }

    }


}

