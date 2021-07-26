//
//  CategoryTableViewCell.swift
//  MyDuesApp
//
//  Created by Venoli Gamage on 2021-05-16.
//
//

import UIKit
import CoreData

class CategoryTableViewCell: UITableViewCell {
    
    var cellDelegate: ProjectTableViewCellDelegate?
    var note: String = "Not Available"

    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var categoryView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func handleViewNotesClick(_ sender: Any) {
        self.cellDelegate?.customCell(cell: self, sender: sender as! UIButton, data: note)
    }
    
    func commonInit(_ categoryName: String, taskProgress: CGFloat, color: String, monthlyBudget: Double, notes: String, numberOfTaps: Int) {


        categoryNameLabel.text = categoryName
        budgetLabel.text = String(monthlyBudget)
        self.note = notes
        notesTextView.text = self.note
        categoryView.backgroundColor = UIColor(hex: color) 
        let height = bounds.size.height
        categoryView.layer.cornerRadius = height * 0.2
        
    }
   
} 

protocol ProjectTableViewCellDelegate {
    func customCell(cell: CategoryTableViewCell, sender button: UIButton, data: String)
}

 
