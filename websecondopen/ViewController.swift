//
//  ViewController.swift
//  websecondopen
//
//  Created by 冯笑 on 2021/4/26.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet var tableView: UITableView!
    
    let datasoures = ["https://static-h5-staging.mofaxiao.com/cactus-h5-app/staging/0.4.38/blankRouter?version=\(Int(Date().timeIntervalSince1970))",
                      "https://static-h5-staging.mofaxiao.com/cactus-h5-for-app-student/staging/0.2.9/blankRouter?version=\(Int(Date().timeIntervalSince1970))",]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasoures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") {
            cell.textLabel?.text = datasoures[indexPath.row]
            return cell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
            cell?.textLabel?.text = datasoures[indexPath.row]
            return cell!
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        let index = indexPath.row
        let urlString = datasoures[index]
        let vc = WebViewController(urlString: urlString)
        navigationController?.pushViewController(vc, animated: true)
    }
}



