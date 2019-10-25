//
//  AddPlaceViewController.swift
//  Places Anniversaries
//
//  Created by Sameh Salama on 10/24/19.
//  Copyright © 2019 Sameh Salama. All rights reserved.
//

import UIKit

protocol AddPlaceDelegate {
    func didAdd(place:Place)
}
class AddPlaceViewController: PlaceDetailViewController {

    
    //MARK: - Properties
    override var didPickImage:Bool {
        didSet {
            didPickImageIsSetTo(didPickImage)
        }
    }
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(AddPlaceViewController.saveBarButtonItemAction(_:)))
        navigationItem.rightBarButtonItem = saveBarButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePlaceImageButtonAction(UIButton())
    }
    
    //MARK: - IBActions
    @IBAction override func updatePlaceImageButtonAction(_ sender: UIButton) {
        let imageSourceAlert = UIAlertController(title: "Add place photo", message: "Please select place image source", preferredStyle: .actionSheet)
        imageSourceAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
            self.openCamera()
        }))
        imageSourceAlert.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (_) in
            self.openPhotos()
        }))
        imageSourceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.dismiss(animated: true) {}
        }))
        if let imageSourceAlertPopover = imageSourceAlert.popoverPresentationController {
            imageSourceAlertPopover.sourceView = self.placeImageView
            imageSourceAlertPopover.sourceRect = self.placeImageView.frame
        }
        DispatchQueue.main.async {
            self.present(imageSourceAlert, animated: true)
        }
    }
    
    
    @IBAction override func showOnMapButtonAction(_ sender: UIButton) {
        let placeLocationVC = storyboard?.instantiateViewController(withIdentifier: "place location vc") as! PlaceLocationViewController
        placeLocationVC.placeName = place.name
        placeLocationVC.delegate = self
        let placeLocationNav = UINavigationController(rootViewController: placeLocationVC)
        present(placeLocationNav, animated: true)
    }
    
    
    //MARK: - Selectors
    @objc private func saveBarButtonItemAction(_ sender: UIBarButtonItem) {
        if isValide(place: place) {
            addPlace(place) { (placeId) in
                if let placeId = placeId {
                    self.place.id = placeId
                    self.upload(image: self.placeImageView.image!, placeId: placeId) { (placeImageUrlString) in
                        if let placeImageUrlString = placeImageUrlString {
                            self.place.imageUrl = placeImageUrlString
                            self.updatePlace(self.place) { (updated) in
                                if updated {
                                    self.dismiss(animated: true) {
                                        self.addPlacDelegate?.didAdd(place: self.place)
                                    }
                                }
                                else {
                                    self.dismiss(animated: true) {}
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //MARK: - Custom Functions
    func isValide(place:Place) -> Bool {
        guard let placeName = place.name else {return false}
        guard !placeName.isEmpty else {return false}
        guard let placeAnniversaries = place.anniversaries else {return false}
        guard !placeAnniversaries.isEmpty else {return false}
        guard let placeLocation = place.location , let _ = placeLocation.first, let _ = placeLocation.last else {return false}
        return true
    }
    
    override func didPickImageIsSetTo(_ newValue: Bool) {
        if newValue {
            showOnMapButtonAction(UIButton())
        }
    }

    private func addPlace(_ place:Place, completion: @escaping (String?) -> Void) {
        FirebaseManager.addPlace(place) { (placeId) in
            DispatchQueue.main.async {
                completion(placeId)
            }
        }
    }

}

extension AddPlaceViewController {
    override func didAdd(anniversary: String) {
        place.anniversaries = []
        place.anniversaries.append(anniversary)
        anniversariesTableView.reloadData()
        
        saveBarButtonItemAction(navigationItem.rightBarButtonItem!)
    }
    
    func didCancelAddingAnniversary() {
        dismiss(animated: true)
    }
}

extension AddPlaceViewController {
    override func didUpdatePlaceLocation(latitude: Double, longitude: Double) {
        place.location = [latitude, longitude]
        let placeAnniversaryVC = storyboard?.instantiateViewController(withIdentifier: "place anniversary vc") as! PlaceAnniversaryViewController
        placeAnniversaryVC.delegate = self
        let placeAnniversaryNav = UINavigationController(rootViewController: placeAnniversaryVC)
        present(placeAnniversaryNav, animated: true)
    }
    
    func didCancelUpdatingPlaceLocation() {
        dismiss(animated: true)
    }
}
