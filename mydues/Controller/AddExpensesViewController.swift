//
//  AddExpensesViewController.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//


import Foundation
import UIKit
import CoreData
import UserNotifications

class AddExpensesViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate, UNUserNotificationCenterDelegate {
    
    var expenses: [NSManagedObject] = []
    let dateFormatter : DateFormatter = DateFormatter()
    var startDatePickerVisible = false
    var dueDatePickerVisible = false
    var taskProgressPickerVisible = false
    var selectedProject: Category?
    var editingMode: Bool = false
    let now = Date()
    
    let formatter: Formatter = Formatter()
    let notificationCenter = UNUserNotificationCenter.current()
    

    @IBOutlet weak var addExpenseButton: UIBarButtonItem!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var addNoteTextField: UITextField!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var addToCalenderSwitch: UISwitch!
    @IBOutlet weak var occurrenceSegmentedControl: UISegmentedControl!
    
    
    
    var editingTask: Expense? {
        didSet {
            // Update the view.
            editingMode = true
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure User Notification Center
        notificationCenter.delegate = self
        
        
        if !editingMode {
            

        }
        
        configureView()
        // Disable add button
        toggleAddButtonEnability()
    }
    
    func configureView() {
        if editingMode {
            self.navigationItem.title = "Edit Expense"
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            
        }
        
        if let expense = editingTask {
            if let amount = amountTextField {
                amount.text = String(expense.amount)
            }
            if let addNote = addNoteTextField {
                addNote.text = expense.notes
            }
            if let dueDate = dueDateLabel {
                dueDate.text = formatter.formatDate(expense.date as Date)
            }
            if let datePicker = dueDatePicker {
                datePicker.date = expense.date as Date
            }

            if let occurrence = occurrenceSegmentedControl {
                occurrence.selectedSegmentIndex = expense.occurrence
            }
            if let addToCalender = addToCalenderSwitch {
                addToCalenderButtonState(date: expense.date as Date)
                addToCalender.setOn(expense.reminder, animated: true)
            }

        }
    }
    @IBAction func occurrenceChanged(_ sender: UISegmentedControl) {
        addToCalenderButtonState(date: dueDatePicker.date)
        
    }
    

    @IBAction func dueDateChanged(_ sender: UIDatePicker) {
        dueDateLabel.text = formatter.formatDate(sender.date)
        addToCalenderButtonState(date: sender.date)
     
    }
    
    func addToCalenderButtonState(date: Date){
        let now = Date()
        
        if(now < date || occurrenceSegmentedControl.selectedSegmentIndex != 0){
            addToCalenderSwitch.isEnabled = true
        }else{
            addToCalenderSwitch.setOn(false, animated: true)
            addToCalenderSwitch.isEnabled = false
        }
    }

    @IBAction func handleCancelButtonClick(_ sender: UIBarButtonItem) {
        dismissAddTaskPopOver()
    }
    
    @IBAction func handleAddButtonClick(_ sender: UIBarButtonItem) {
        if validate() {
            let expenseAmount = Double(amountTextField.text ?? "0.0")
            let dueDate = dueDatePicker.date
//            let progress = Float(progressSlider.value * 100)
            let notes = addNoteTextField.text
            let reminder = Bool(addToCalenderSwitch.isOn)
            let expenseOccurrence = occurrenceSegmentedControl.selectedSegmentIndex
            
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Expense", in: managedContext)!
            
            var expense = NSManagedObject()
            
            if editingMode {
                expense = (editingTask as? Expense)!
            } else {
                expense = NSManagedObject(entity: entity, insertInto: managedContext)
            }
            
            if addToCalenderSwitch.isEnabled && addToCalenderSwitch.isOn {
//                let manager = LocalNotificationManager()
//                manager.notifications.append(Notifications(id: Notification.Name(rawValue: "MyDues").rawValue, title: notes ?? "Payment", datetime: dueDatePicker.calendar.dateComponents([.minute, .hour, .day, .month, .year],from: dueDatePicker.date)))
//
//                manager.schedule()
                
                CalanderHelper.createEvent(title: "Reminder on \(notes ?? "")", endDate: dueDatePicker.date, occur: expenseOccurrence) {
                                (status, result) in
                            }
            }
            
            expense.setValue(expenseAmount, forKeyPath: "amount")
            expense.setValue(notes, forKeyPath: "notes")
            expense.setValue(dueDate, forKeyPath: "date")
            expense.setValue(reminder, forKeyPath: "reminder")
            expense.setValue(expenseOccurrence, forKey: "occurrence")
            selectedProject?.addToExpense((expense as? Expense)!)
            
            do {
                try managedContext.save()
                expenses.append(expense)
            } catch _ as NSError {
                let alert = UIAlertController(title: "Error", message: "An error occured while saving the task.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Please fill the required fields.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        // Dismiss PopOver
        dismissAddTaskPopOver()
    }
    
    func scheduleLocalNotification(_ title: String, subtitle: String, body: String, date: Date) {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        let identifier = "\(UUID().uuidString)"
        
        // Configure Notification Content
        notificationContent.title = title
        notificationContent.subtitle = subtitle
        notificationContent.body = body
        
        // Add Trigger
        // let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 20.0, repeats: false)
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        
        // Add Request to User Notification Center
        notificationCenter.add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
    func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(success)
        }
    }

    @IBAction func textInputChanged(_ sender: UITextField) {
        toggleAddButtonEnability()
    }
    
    // Handles the add button enable state
    func toggleAddButtonEnability() {
        if validate() {
            addExpenseButton.isEnabled = true;
        } else {
            addExpenseButton.isEnabled = false;
        }
    }
    
    // Dismiss Popover
    func dismissAddTaskPopOver() {
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
    // Check if the required fields are empty or not
    func validate() -> Bool {
        if !(amountTextField.text?.isEmpty)! && !(addNoteTextField.text?.isEmpty)! && Double(amountTextField.text!) != nil{
            return true
        }
        return false
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}

// MARK: - UITableViewDelegate
extension AddExpensesViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            amountTextField.becomeFirstResponder()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            amountTextField.becomeFirstResponder()
        }
        
        // Section 1 contains start date(index: 0), end date(index: 1) and add to callender(inddex: 1) rows
        if(indexPath.section == 1 && indexPath.row == 0) {
            startDatePickerVisible = !startDatePickerVisible
            tableView.reloadData()
        }
        if(indexPath.section == 1 && indexPath.row == 2) {
            dueDatePickerVisible = !dueDatePickerVisible
            tableView.reloadData()
        }
        
        // Section 2 contains task progress
        if(indexPath.section == 2 && indexPath.row == 0) {
            taskProgressPickerVisible = !taskProgressPickerVisible
            tableView.reloadData()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            if startDatePickerVisible == false {
                return 0.0
            }
            return 250.0
        }
        if indexPath.section == 1 && indexPath.row == 3 {
            if dueDatePickerVisible == false {
                return 0.0
            }
            return 250.0
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            if taskProgressPickerVisible == false {
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
