//
//  PlacesViewController.swift
//  Places Anniversaries
//
//  Created by Sameh Salama on 10/22/19.
//  Copyright © 2019 Sameh Salama. All rights reserved.
//

import UIKit

/// Responsible for managing a view that retrieves and display Place objects
class PlacesViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var noPlacesLabel: UILabel!
    
    // MARK: - Properties
    /// Place objects array that shows or hides help label if no Place objects
    var places:[Place] = [] {
        didSet {
            placesTableView.isHidden = places.isEmpty
            noPlacesLabel.isHidden = !placesTableView.isHidden
            places.sort {$0.name.lowercased() < $1.name.lowercased()}
            if navigationItem.rightBarButtonItem != nil && navigationItem.rightBarButtonItems!.count == 2 {
                navigationItem.rightBarButtonItems![1].title = places.isEmpty ? "" : placesTableView?.isEditing == true ? "Done" : "Edit"
            }
        }
    }
    /// For pagination
    var queryCount:Int = 0
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Places"
        
        placesTableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "place table view cell")
        placesTableView.dataSource = self
        placesTableView.delegate = self
        placesTableView.tableFooterView = UIView()
        
        let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(PlacesViewController.refreshBarButtonItemAction(_:)))
        navigationItem.rightBarButtonItem = refreshBarButtonItem
        
        refreshBarButtonItemAction(refreshBarButtonItem)
    }
    
    
    // MARK: - Selectors
    /// Sign in to Firebase anonymously and gets Place objects upon successful signing, or retries signing in
    /// - Parameter sender: Refresh bar button item, or any other barbutton itesm
    @objc private func refreshBarButtonItemAction(_ sender: UIBarButtonItem) {
        anonymouslySignInToFirebase { (userUid) in
            if let _ = userUid {
                let editBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(PlacesViewController.editBarButtonItemAction(_:)))
                let addPlaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(PlacesViewController.addPlaceBarButtonItemAction(_:)))
                self.navigationItem.rightBarButtonItems = [addPlaceBarButtonItem, editBarButtonItem]
                self.getPlaces(lastPlaceName: self.places.last?.name) { (places, queryCount) in
                    self.placesTableView.reloadData()
                }
            }
            else {
                self.refreshBarButtonItemAction(sender)
            }
        }
    }

    @objc private func addPlaceBarButtonItemAction(_ sender: UIBarButtonItem) {
        let addPlaceAlert = UIAlertController(title: "Add Place", message: "", preferredStyle: .alert)
        addPlaceAlert.addTextField { (placeNameTextField) in
            placeNameTextField.placeholder = "Enter place name"
        }
        addPlaceAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let placeNameTextField = addPlaceAlert.textFields?.first else {return}
            guard let placeName = placeNameTextField.text else {return}
            guard !placeName.isEmpty else {return}
            
            let addPlaceVC = PlaceDetailViewController.instantiate(as: AddPlaceViewController.self)!
            let newPlace = Place()
            newPlace.name = placeName
            addPlaceVC.place = newPlace
            addPlaceVC.addPlacDelegate = self
            addPlaceVC.modalPresentationStyle = .fullScreen
            self.present(addPlaceVC, animated: true)
        }))
        addPlaceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        DispatchQueue.main.async {
            self.present(addPlaceAlert, animated: true)
        }
    }
    
    @objc private func editBarButtonItemAction(_ sender: UIBarButtonItem) {
        super.setEditing(!placesTableView.isEditing, animated: true)
        placesTableView.setEditing(!placesTableView.isEditing, animated: true)
        sender.title = placesTableView.isEditing ? "Done" : "Edit"
    }
    
    // MARK: - Custom Functions
    private func anonymouslySignInToFirebase(completion: @escaping (String?) -> Void) {
        FirebaseManager.anonymouslySignInToFirebase { (userUid) in
            DispatchQueue.main.async {
                completion(userUid)
            }
        }
    }
    
    private func getPlaces(lastPlaceName: String?, completion: @escaping (([Place]?, Int?) -> Void)) {
        FirebaseManager.getPlaces(lastPlaceName: lastPlaceName) { (places, queryCount) in
            if let queryCount = queryCount {
                self.queryCount = queryCount
            }
            if let places = places {
                self.places.append(contentsOf: places)
            }
            DispatchQueue.main.async {
                completion(places, queryCount)
            }
        }
    }
    
    private func deletePlace(at:Int) {
        FirebaseManager.deletePlace(places[at].id) { (deleted) in
            if deleted {
                self.places.remove(at: at)
                DispatchQueue.main.async {
                    self.placesTableView.deleteRows(at: [IndexPath(row: at, section: 0)], with: .automatic)
                }
            }
        }
    }
    
}


extension PlacesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "place table view cell") as! PlaceTableViewCell
        let place = places[indexPath.row]
        cell.placeNameLabel.text = place.name
        if let anniversaries = place.anniversaries {
            var anniversariesString:String = ""
            for anniversary in anniversaries {
                if anniversariesString.isEmpty {
                    anniversariesString = "• \(anniversary)"
                }
                else {
                    anniversariesString.append("\n• \(anniversary)")
                }
            }
            cell.placeAnniversariesLabel.text = anniversariesString
        }
        if let placeImageUrlString = place.imageUrl, let placeImageUrl = URL(string: placeImageUrlString) {
            cell.placeImageView.kf.setImage(with: placeImageUrl, placeholder: UIImage(named:"imagePlaceholder"))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeDetailVC = storyboard?.instantiateViewController(withIdentifier: "place detail vc") as! PlaceDetailViewController
        placeDetailVC.place = places[indexPath.row]
        placeDetailVC.delegate = self
        placeDetailVC.placeIndex = indexPath.row
        placeDetailVC.modalPresentationStyle = .fullScreen
        present(placeDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == places.count - 1 && queryCount >= FirebaseManager.pageSize {
            getPlaces(lastPlaceName: places.last?.name) { (places, queryCount) in
                
                DispatchQueue.main.async {
                    self.placesTableView.reloadData()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            deletePlace(at:indexPath.row)
        }
    }
    
}

extension PlacesViewController: PlaceDetailDelegate {
    func didEditPlace(at: Int) {
        placesTableView.reloadRows(at: [IndexPath(row: at, section: 0)], with: .none)
    }
}

extension PlacesViewController: AddPlaceDelegate {
    func didAdd(place: Place) {
        places.append(place)
        placesTableView.reloadData()
    }
}
