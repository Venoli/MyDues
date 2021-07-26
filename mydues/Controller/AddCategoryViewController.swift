//
//  AddCategoryViewController.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//

import Foundation
import UIKit
import CoreData
import EventKit

class AddCategoryViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate {
    
    var projects: [NSManagedObject] = []
    var datePickerVisible = false
    var editingMode: Bool = false
    let now = Date();
    
    let formatter: Formatter = Formatter()
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var addNotesTextField: UITextField!
    @IBOutlet weak var addCategoryButton: UIBarButtonItem!
    @IBOutlet var addFormTableView: UITableView!
    
    
    
    var editingProject: Category? {
        didSet {
            // Update the view.
            editingMode = true
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        addFormTableView.backgroundColor = UIColor(hex: "#00000000")
        configureView()
        // Disable add button
        toggleAddButtonEnability()
    }
    
    func configureView() {
        if editingMode {
            self.navigationItem.title = "Edit Category"
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        
        if let project = editingProject {
            if let categoryName = categoryNameTextField {
                categoryName.text = editingProject?.name
            }
            if let budget = budgetTextField {
                budget.text = String(editingProject!.monthlyBudget)
            }
           
            if let addNotes = addNotesTextField {
                addNotes.text = editingProject?.notes
            }
           
        }
    }

    
    @IBAction func handleCancelButtonClick(_ sender: UIBarButtonItem) {
        dismissAddProjectPopOver()
    }
    
    @IBAction func handleAddButtonClick(_ sender: UIBarButtonItem) {
        if validate() {

            
            let categoryName = categoryNameTextField.text
            let budget = Double(budgetTextField.text ?? "0.0")
            let notes = addNotesTextField.text
            let color = String((addFormTableView.backgroundColor?.hexStringFromColor()) ?? "#ffffff")
            var numberOfTaps = Int64(0)

            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedContext)!
            
            var category = NSManagedObject()
            
            if editingMode {
                category = (editingProject as? Category)!
                numberOfTaps = editingProject?.numberOfTaps ?? 0
            } else {
                category = NSManagedObject(entity: entity, insertInto: managedContext)
            }
            

            category.setValue(categoryName, forKeyPath: "name")
            category.setValue(notes, forKeyPath: "notes")
        
            category.setValue(budget, forKeyPath: "monthlyBudget")
            category.setValue(color, forKeyPath: "colour")
            category.setValue(numberOfTaps, forKey: "numberOfTaps")
            
            print(category)
            
            do {
                try managedContext.save()
                projects.append(category)
            } catch _ as NSError {
                let alert = UIAlertController(title: "Error", message: "An error occured while saving the project.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Please fill the required fields.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        // Dismiss PopOver
        dismissAddProjectPopOver()
    }

    
 
    @IBAction func categoryNameChange(_ sender: Any) {
        toggleAddButtonEnability()
    }
    

    
    // Handles the add button enable state
    func toggleAddButtonEnability() {
        if validate() {
            addCategoryButton.isEnabled = true;
        } else {
            addCategoryButton.isEnabled = false;
        }
    }
    
    // Dismiss Popover
    func dismissAddProjectPopOver() {
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
    // Check if the required fields are empty or not
    func validate() -> Bool {
        if !(categoryNameTextField.text?.isEmpty)! && !(addNotesTextField.text?.isEmpty)! && !(budgetTextField.text?.isEmpty)! &&
            Double(budgetTextField.text!) != nil {
            return true
        }
        return false
    }
    
    // Setting the selected priority back on the selection view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
  
  
    @IBAction func clickColorButton(_ sender: UIButton) {
        addFormTableView.backgroundColor = sender.backgroundColor
    }
    
    
}

// MARK: - UITableViewDelegate
extension AddCategoryViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            categoryNameTextField.becomeFirstResponder()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            addNotesTextField.becomeFirstResponder()
        }
        
        // Section 1 contains end date(inddex: 0) and add to callender(inddex: 1) rows
        if(indexPath.section == 1 && indexPath.row == 0) {
            datePickerVisible = !datePickerVisible
            tableView.reloadData()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            if datePickerVisible == false {
                return 0.0
            }
            return 200.0
        }
        // Make Notes text view bigger: 80
        if indexPath.section == 0 && indexPath.row == 1 {
            return 80.0
        }
        
        return 50.0
    }
}

// MARK: - IBActions
extension AddCategoryViewController {
    
}
