//
//  MasterViewController.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//


import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet var projectsTable: UITableView!
    
    let calculations: Calculations = Calculations()
     var isAlphebatic: Bool = false{
        didSet {
            _fetchedResultsController = nil
            tableView.reloadData()
            
        }
    }
    
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // initializing the custom cell
        let nibName = UINib(nibName: "CategoryTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "ProjectCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        // Set the default selected row
        autoSelectTableRow()
    }
    

    
@IBAction func sortAlphabeticalOrder(_ sender: UIBarButtonItem) {
    isAlphebatic = true
    
}
    
    
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
  
        do {
            try context.save()
        } catch {
          
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            // perform segue
            let object = fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "showProjectDetails", sender: object)
            //update selected indexPath
            selectedIndexPath = indexPath
            // update tap count
            updateTapCount(clickedCategory: object)
           
        }
        
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProjectDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.selectedProject = object as Category
            }
        }
        
        if segue.identifier == "addProject" {
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 320, height: 300)
            }
        }
        
        if segue.identifier == "editProject" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! AddCategoryViewController
                controller.editingProject = object as Category
                controller.preferredContentSize = CGSize(width: 320, height: 300)
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! CategoryTableViewCell
        let project = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withProject: project)
        cell.cellDelegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        autoSelectTableRow()
    }
    
    func updateTapCount(clickedCategory: Category) {
        let categoryName = clickedCategory.name
   

        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedContext)!
        
        var category = NSManagedObject()
        
        category = (clickedCategory as? Category)!
        let numberOfTaps = clickedCategory.numberOfTaps + 1

        category.setValue(clickedCategory.name, forKeyPath: "name")
        category.setValue(clickedCategory.notes, forKeyPath: "notes")
        category.setValue(clickedCategory.monthlyBudget, forKeyPath: "monthlyBudget")
        category.setValue(clickedCategory.colour, forKeyPath: "colour")
        category.setValue(numberOfTaps, forKey: "numberOfTaps")
        
        print(category)
        
        do {
            try managedContext.save()
        } catch _ as NSError {
         print("Error")
        }
    
    
        }
    
    func configureCell(_ cell: CategoryTableViewCell, withProject project: Category) {
        let projectProgress = calculations.getProjectProgress(project.expense!.allObjects as! [Expense])
        cell.commonInit(project.name, taskProgress: CGFloat(projectProgress), color: project.colour, monthlyBudget: project.monthlyBudget, notes: project.notes, numberOfTaps: Int(project.numberOfTaps))
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Category> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
//        let sortDescriptor = NSSortDescriptor(key: "numberOfTaps", ascending: true)
       var sortDescriptor = NSSortDescriptor(key: "numberOfTaps", ascending: false, selector: #selector(NSNumber.compare(_:)))
        if isAlphebatic{
            sortDescriptor = NSSortDescriptor(key: "name", ascending: true)

        }
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        // update UI
        autoSelectTableRow()
        
        return _fetchedResultsController!
    }
    
    
    
    var _fetchedResultsController: NSFetchedResultsController<Category>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)! as! CategoryTableViewCell, withProject: anObject as! Category)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)! as! CategoryTableViewCell, withProject: anObject as! Category)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        
        // update UI
        autoSelectTableRow()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    
    func showPopoverFrom(cell: CategoryTableViewCell, forButton button: UIButton, forNotes notes: String) {
        let buttonFrame = button.frame
        var showRect = cell.convert(buttonFrame, to: projectsTable)
        showRect = projectsTable.convert(showRect, to: view)
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

    func autoSelectTableRow() {
       
        if tableView.hasRowAtIndexPath(indexPath: selectedIndexPath as NSIndexPath) {
            tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .bottom)
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                self.performSegue(withIdentifier: "showProjectDetails", sender: object)
            }
        } else {
            let empty = {}
            self.performSegue(withIdentifier: "showProjectDetails", sender: empty)
        }
    }
}

extension MasterViewController: ProjectTableViewCellDelegate {
    func customCell(cell: CategoryTableViewCell, sender button: UIButton,data data: String) {
        self.showPopoverFrom(cell: cell, forButton: button, forNotes: data)
    }
}
