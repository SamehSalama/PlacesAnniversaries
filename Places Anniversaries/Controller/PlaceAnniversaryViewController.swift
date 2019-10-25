//
//  PlaceAnniversaryViewController.swift
//  Places Anniversaries
//
//  Created by Sameh Salama on 10/23/19.
//  Copyright © 2019 Sameh Salama. All rights reserved.
//

import UIKit

@objc protocol PlaceAnniversaryDelegate {
    @objc optional func didAdd(anniversary:String)
    @objc optional func didCancelAddingAnniversary()
}

/// Responsible for managing a view that adds Place anniversary
class PlaceAnniversaryViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var placeAnniversaryNameTextField: UITextField!
    @IBOutlet weak var anniversaryDatePicker: UIDatePicker!
    
    // MARK: - Properties
    var delegate: PlaceAnniversaryDelegate? = nil
    private var anniversaryName:String!
    private var anniversaryDate:String!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PlaceAnniversaryViewController.doneBarButtonItemAction(_:)))
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PlaceAnniversaryViewController.cancelBarButtonItemAction(_:)))
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        
        placeAnniversaryNameTextField.becomeFirstResponder()
    }
    
    // MARK: - IBActions
    @IBAction func anniversaryDatePickerAction(_ sender: UIDatePicker) {
        view.endEditing(true)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        anniversaryDate = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func anniversaryNameTextFieldEditingChanged(_ sender: UITextField) {
        anniversaryName = sender.text        
    }
    
    // MARK: - Selectors
    @objc private func doneBarButtonItemAction(_ sender: UIBarButtonItem) {
        guard let anniversaryName = anniversaryName, let anniversaryDate = anniversaryDate else {
            let alert = UIAlertController(title: "Anniversary Details", message: "anniversary name and date are both required", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
            return
        }
        guard !anniversaryName.isEmpty else {return}
        let anniversaryString = anniversaryName + " - " + anniversaryDate

        dismiss(animated: true) {
            self.delegate?.didAdd?(anniversary: anniversaryString)
        }
    }
    
    @objc private func cancelBarButtonItemAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {
            self.delegate?.didCancelAddingAnniversary?()
        }
    }

}
