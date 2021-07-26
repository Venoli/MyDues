//
//  ExpensesTableViewCell.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//


import UIKit

class ExpensesTableViewCell: UITableViewCell {
    
    var cellDelegate: TaskTableViewCellDelegate?
    var notes: String = "Not Available"

    @IBOutlet weak var daysLeftLabel: UILabel!

    @IBOutlet weak var dueDateLabel: UILabel!

    @IBOutlet weak var expenseProportionProgressBar: LinearProgressBar!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var occurrenceLabel: UILabel!
    @IBOutlet weak var reminderIcon: UIImageView!
    
    let now: Date = Date()
    let colours: Colours = Colours()
    let formatter: Formatter = Formatter()
    let calculations: Calculations = Calculations()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func handleViewNotesClick(_ sender: Any) {
        print("click")
        self.cellDelegate?.viewNotes(cell: self, sender: sender as! UIButton, data: notes)
    }
    
    func commonInit(_ notes: String, taskProgress: CGFloat, date: Date, amount: Double, occurrence: Int, reminder: Bool, selectedProject: Category) {
        let (daysLeft, hoursLeft, minutesLeft) = calculations.getTimeDiff(now, end: date)
        
//        let remainingDaysPercentage = calculations.getRemainingTimePercentage(startDate, end: dueDate)
        
        noteLabel.text = notes
        dueDateLabel.text = "Due: \(formatter.formatDate(date))"
        daysLeftLabel.text = "\(daysLeft) Days \(hoursLeft) Hours \(minutesLeft) Minutes Remaining"
        if(occurrence == 0){
            occurrenceLabel.text = "One off"
        }else if(occurrence == 1){
            occurrenceLabel.text = "Daily"
        }else if(occurrence == 2){
            occurrenceLabel.text = "Weekly"
        }else if(occurrence == 3){
            occurrenceLabel.text = "Monthly"
        }
       
        
    
        let percentage = calculations.getExpenseProportionPercentage(totalBudget: selectedProject.monthlyBudget, expenceAmount: amount)
        
        DispatchQueue.main.async {
            let colours = self.colours.getProgressGradient(percentage, negative: true)
            self.expenseProportionProgressBar.startGradientColor = colours[0]
            self.expenseProportionProgressBar.endGradientColor = colours[1]
            self.expenseProportionProgressBar.progress = CGFloat(percentage) / 100
        }

        amountLabel.text = "£ \(amount)"
        self.notes = notes
        
        if(reminder){
            if #available(iOS 13.0, *) {
                reminderIcon.image = UIImage(systemName: "bell.fill")
                reminderIcon.contentScaleFactor = CGFloat(7)
                reminderIcon.tintColor = UIColor.systemBlue
            } else {
                // Fallback on earlier versions
            }
            
        }else{
            if #available(iOS 13.0, *) {
                reminderIcon.image = UIImage(systemName: "bell.slash.fill")
                reminderIcon.contentScaleFactor = CGFloat(7)
                reminderIcon.tintColor = Constants.Design.Color.appDisabledColor
            } else {
                // Fallback on earlier versions
            }
        }
    }
}


protocol TaskTableViewCellDelegate {
    func viewNotes(cell: ExpensesTableViewCell, sender button: UIButton, data data: String)
}
