//
//  DetailViewController.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//

import UIKit
import CoreData
import EventKit

class DetailViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var expensesTable: UITableView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var spentLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!

    @IBOutlet weak var budgetPieChart: PieCharts!
    @IBOutlet weak var categoryDetailView: UIView!
    @IBOutlet weak var addExpenseButton: UIBarButtonItem!
    @IBOutlet weak var editExpenseButton: UIBarButtonItem!
    @IBOutlet weak var addToCalendarButton: UIBarButtonItem!
    @IBOutlet weak var highestExpenseLabel: UILabel!
    @IBOutlet weak var secondHighestExpenseLabel: UILabel!
    @IBOutlet weak var thirdHighestExpenseLabel: UILabel!
    @IBOutlet weak var fourthHighestExpenseLabel: UILabel!
    @IBOutlet weak var highestExpenseColor: UIButton!
    @IBOutlet weak var secondHighestExpenseColor: UIButton!
    @IBOutlet weak var thirdHighestExpenseColor: UIButton!
    @IBOutlet weak var fourthHighestExpenseColor: UIButton!
    
    
    let formatter: Formatter = Formatter()
    let calculations: Calculations = Calculations()
    let colours: Colours = Colours()
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    let now = Date()
    
    public var selectedProject: Category? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        configureView()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        self.managedObjectContext = appDelegate.persistentContainer.viewContext
        
        // initializing the custom cell
        let nibName = UINib(nibName: "ExpensesTableViewCell", bundle: nil)
        expensesTable.register(nibName, forCellReuseIdentifier: "TaskCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the default selected row
        let indexPath = IndexPath(row: 0, section: 0)
        if expensesTable.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath) {
            expensesTable.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        }
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newTask = Expense(context: context)
        
      
        do {
            try context.save()
        } catch {
           
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let project = selectedProject {
            if let nameLabel = categoryNameLabel {
                nameLabel.text = project.name
            }
            if let dueDateLabel = dueDateLabel {
                dueDateLabel.text = "Total Budget: \(project.monthlyBudget as Double)"
            }
            if let priorityLabel = notesLabel {
                priorityLabel.text = "Note: \(project.notes)"
            }
    
            
            var tasks = (project.expense!.allObjects as! [Expense])
            // Sort expenses by amount
            tasks = tasks.sorted(by: { $0.amount > $1.amount })
            
            if tasks.count > 0 , let highestExpenseLabel = highestExpenseLabel {
                highestExpenseLabel.text = makeShortNote(str: tasks[0].notes)
                highestExpenseLabel.isHidden = false
                highestExpenseColor.isHidden = false
            }
            if tasks.count > 1 , let secondHighestExpenseLabel = secondHighestExpenseLabel {
                secondHighestExpenseLabel.text = makeShortNote(str: tasks[1].notes)
                secondHighestExpenseLabel.isHidden = false
                secondHighestExpenseColor.isHidden = false
            }
            if tasks.count > 2 , let thirdHighestExpenseLabel = thirdHighestExpenseLabel {
                thirdHighestExpenseLabel.text = makeShortNote(str: tasks[2].notes)
                thirdHighestExpenseLabel.isHidden = false
                thirdHighestExpenseColor.isHidden = false
            }
            if tasks.count > 3 , let fourthHighestExpenseLabel = fourthHighestExpenseLabel {
                fourthHighestExpenseLabel.text = makeShortNote(str: tasks[3].notes)
                fourthHighestExpenseLabel.isHidden = false
                fourthHighestExpenseColor.isHidden = false
            }

            
                
            var expenses = [0.0,0,0,0,0,0]
            var totalExpences = 0.0
            
            for index in 0...3{
                if (tasks.count>index){
                    expenses[index] = tasks[index].amount
                    totalExpences += tasks[index].amount
                }
            }
            if (tasks.count>4){
                var others = 0.0
                for index in 4...tasks.count-1{
                    others += tasks[index].amount
                    totalExpences += tasks[index].amount
                }
                expenses[4] = others
            }
            if let spentLabel = spentLabel {
                spentLabel.text = "Spent: £ \(totalExpences)"
            }
            let remaining = project.monthlyBudget - totalExpences
            
            expenses[5] = abs(remaining)
            // add remaining with total expences to create the pie chart
            totalExpences += abs(remaining)
            if remaining < 0{
                self.budgetPieChart?.outOfBudget = true
                if let remainingLabel = remainingLabel {
                remainingLabel.textColor = UIColor(hex:"#ec5766ff")
                }
            }
            
            if let remainingLabel = remainingLabel {
                remainingLabel.text = "Remaining: £\(remaining)"
            }
            DispatchQueue.main.async {
                self.budgetPieChart?.expenses = expenses
                self.budgetPieChart?.totalBudget = totalExpences
            }
        }
        
        if selectedProject == nil {
            //taskTable.isHidden = true
            //projectDetailView.isHidden = true
        }
    }
   
    func makeShortNote(str: String) -> String{
        var  str = str
        let nsString = str as NSString
        if nsString.length >= 12
        {
        str =  nsString.substring(with: NSRange(location: 0, length: nsString.length > 12 ? 12 : nsString.length))
        str = str + "..."
        }
        return str
    }

    @IBAction func handleAddEventClick(_ sender: Any) {
      
    }
    
    @IBAction func handleRefreshClick(_ sender: Any) {
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddExpensesViewController
            controller.selectedProject = selectedProject
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 320, height: 500)
            }
        }
        
        if segue.identifier == "showProjectNotes" {
            let controller = segue.destination as! NotesPopoverController
            controller.notes = selectedProject!.notes
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 300, height: 250)
            }
        }
        
        if segue.identifier == "editTask" {
            if let indexPath = expensesTable.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! AddExpensesViewController
                controller.editingTask = object as Expense
                controller.selectedProject = selectedProject
            }
        }
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        if selectedProject == nil {
            categoryDetailView.isHidden = true
            budgetPieChart.isHidden = true
            addExpenseButton.isEnabled = false
            editExpenseButton.isEnabled = false
            addToCalendarButton.isEnabled = false
            expensesTable.setEmptyMessage("Add a new Project to manage Tasks", UIColor.black)
     //       return 0
        }
        
        if sectionInfo.numberOfObjects == 0 {
            editExpenseButton.isEnabled = false
            expensesTable.setEmptyMessage("No tasks available for this Project", UIColor.black)
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ExpensesTableViewCell
        let task = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withTask: task, index: indexPath.row)
        cell.cellDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
              
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: ExpensesTableViewCell, withTask task: Expense, index: Int) {
        if (selectedProject != nil){
        //print("Related Project", task.project)
        cell.commonInit(task.notes, taskProgress: CGFloat(5), date: task.date as Date, amount: task.amount as Double, occurrence: task.occurrence, reminder: task.reminder, selectedProject: selectedProject as! Category )
        }
        
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Expense> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        if selectedProject != nil {
            // Setting a predicate
            let predicate = NSPredicate(format: "%K == %@", "category", selectedProject as! Category)
            fetchRequest.predicate = predicate
        }

        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "\(UUID().uuidString)-category")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Expense>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        expensesTable.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            expensesTable.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            expensesTable.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            expensesTable.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            expensesTable.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(expensesTable.cellForRow(at: indexPath!)! as! ExpensesTableViewCell, withTask: anObject as! Expense, index: indexPath!.row)
        case .move:
            configureCell(expensesTable.cellForRow(at: indexPath!)! as! ExpensesTableViewCell, withTask: anObject as! Expense, index: indexPath!.row)
            expensesTable.moveRow(at: indexPath!, to: newIndexPath!)
        }
        configureView()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        expensesTable.endUpdates()
    }
    
    func showPopoverFrom(cell: ExpensesTableViewCell, forButton button: UIButton, forNotes notes: String) {
        let buttonFrame = button.frame
        var showRect = cell.convert(buttonFrame, to: expensesTable)
        showRect = expensesTable.convert(showRect, to: view)
        showRect.origin.y -= 5
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NotesPopoverController") as? NotesPopoverController
        controller?.modalPresentationStyle = .popover
        controller?.preferredContentSize = CGSize(width: 300, height: 250)
        controller?.notes = notes
        
        if let popoverPresentationController = controller?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = showRect
            
            if let popoverController = controller {
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    // Creates an event in the EKEventStore
    func createEvent(_ eventStore: EKEventStore, title: String, startDate: Date, endDate: Date) -> String {
        let event = EKEvent(eventStore: eventStore)
        var identifier = ""
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            identifier = event.eventIdentifier
        } catch {
            let alert = UIAlertController(title: "Error", message: "Calendar event could not be created!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        return identifier
    }
}

extension DetailViewController: TaskTableViewCellDelegate {
    func viewNotes(cell: ExpensesTableViewCell, sender button: UIButton, data data: String) {
        self.showPopoverFrom(cell: cell, forButton: button, forNotes: data)
    }
}
