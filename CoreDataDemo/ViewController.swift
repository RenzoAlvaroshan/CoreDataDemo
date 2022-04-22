//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Renzo Alvaroshan on 21/04/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Data for the table
    var items: [Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get items from Core Data
        fetchPeople()
    }
    
    func fetchPeople() {
        
        // Fetch the data from Core Data to display in the tableView
        do {
            self.items = try context.fetch(Person.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print(error)
        }
    }

    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        
        // Create alert
        let alert = UIAlertController(title: "Add Person", message: "What is their name?", preferredStyle: .alert)
        alert.addTextField()
        
        // Configure button handler
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // Get the textField for the alert
            let textField = alert.textFields![0]
            
            // Create a person object
            let newPerson = Person(context: self.context)
            newPerson.name = textField.text
            newPerson.age = 20
            newPerson.gender = "Male"
            
            // Save the data
            do {
                try self.context.save()
            } catch {
                print(error)
            }
            
            // Re-fetch the data
            self.fetchPeople()
        }
        
        // Add button
        alert.addAction(submitButton)
        
        // Show alert
        self.present(alert, animated: true)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of people
        return self.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)
        
        // Get person from array and set the label
        let person = self.items![indexPath.row]
        
        cell.textLabel?.text = person.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Selected Person
        let person = self.items![indexPath.row]
        
        // Create alert
        let alert = UIAlertController(title: "Edit Person", message: "Edit name:", preferredStyle: .alert)
        alert.addTextField()
        
        let textField = alert.textFields![0]
        textField.text = person.name
        
        // Configure button handler
        let saveButton = UIAlertAction(title: "Save", style: .default) { (action) in
            
            // Get the textfield for the alert
            let textField = alert.textFields![0]
            
            // Edit name property of person object
            person.name = textField.text
            
            // Save the data
            do {
                try self.context.save()
            } catch {
                
            }
            
            // Re-fetch the data
            self.fetchPeople()
            
        }
        
        // Add button
        alert.addAction(saveButton)
        
        // Show alert
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            // Which person to remove
            let personToRemove = self.items![indexPath.row]
            
            // Remove the person
            self.context.delete(personToRemove)
            
            // Save the data
            do {
                try self.context.save()
            } catch {
                
            }
            
            // Re-fetch the data
            self.fetchPeople()
        }
        
        // Return swipe actions
        return UISwipeActionsConfiguration(actions: [action])
    }
}
