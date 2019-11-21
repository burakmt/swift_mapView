//
//  MainController.swift
//  TravelBook
//
//  Created by Bera on 21.11.2019.
//  Copyright © 2019 Bera. All rights reserved.
//

import UIKit
import CoreData

class MainController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var travelTitle = [String]()
    var travelID = [UUID]()
    
    var chosenTitle = String()
    var chosenID = UUID()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self,                                                    action: #selector(addTravel))
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    @objc func addTravel(){
        chosenTitle = ""
        performSegue(withIdentifier: "addToVC", sender: nil)
    }
    @objc func getData(){
        travelTitle.removeAll(keepingCapacity: false)
        travelID.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "Travel")
        fetchResult.returnsObjectsAsFaults = false
        
        do{
            let result = try context.fetch(fetchResult)

            if result.count > 0{
                for item in result as! [NSManagedObject]{
                    if let dataTitle = item.value(forKey: "title") as? String{
                        self.travelTitle.append(dataTitle)
                    }
                    if let dataId = item.value(forKey: "id") as? UUID{
                        self.travelID.append(dataId)
                    }
                    
                    self.tableView.reloadData()
                }
            }
        }
        catch{
            print("Error")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = travelTitle[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchResult = NSFetchRequest<NSFetchRequestResult>(entityName: "Travel")
            let idString = travelID[indexPath.row].uuidString
            fetchResult.predicate = NSPredicate(format: "id = %@", idString)
            
            do{
                let result = try context.fetch(fetchResult)
                if result.count > 0{
                    for item in result as! [NSManagedObject]{
                        context.delete(item)
                        travelTitle.remove(at: indexPath.row)
                        travelID.remove(at: indexPath.row)
                        
                        self.tableView.reloadData()
                        
                        do{
                            try context.save()
                        }
                        catch{
                            print("Delete Error")
                        }
                    }
                }
            }
            catch{
                print("Error")
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return travelID.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = travelTitle[indexPath.row]
        chosenID = travelID[indexPath.row]
        performSegue(withIdentifier: "addToVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addToVC"{
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = chosenTitle
            destinationVC.selectedID = chosenID
        }
    }
}
