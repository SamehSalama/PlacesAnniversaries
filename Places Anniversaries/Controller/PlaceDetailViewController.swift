//
//  PlaceDetailViewController.swift
//  Places Anniversaries
//
//  Created by Sameh Salama on 10/24/19.
//  Copyright © 2019 Sameh Salama. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation

protocol PlaceDetailDelegate {
    func didEditPlace(at:Int)
}

class PlaceDetailViewController: UIViewController {

    /// Instentiate View controller from Main storyboard and retrun it as Child view controller
    /// - Parameter as: Child view controller class self
    class func instantiate<T: PlaceDetailViewController>(as _: T.Type) -> T? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let instance = storyboard.instantiateViewController(withIdentifier: "place detail vc") as? PlaceDetailViewController else {
            return nil
        }
        object_setClass(instance, T.self)
        return instance as? T
    }
    
    //MARK: - IBOutles
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameTextView: UITextView!
    @IBOutlet weak var placeNameTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var anniversariesTableView: UITableView!
    @IBOutlet weak var anniversariesTableViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    var place:Place!
    var delegate:PlaceDetailDelegate? = nil
    var addPlacDelegate:AddPlaceDelegate? = nil
    private let imagePicker = UIImagePickerController()
    private var oldPlaceImage:UIImage!
    private var oldPlaceName:String!
    var placeIndex:Int!
    private let anniversariesTableViewRowHeight:CGFloat = 50
    var didPickImage:Bool = false {
        didSet {
            didPickImageIsSetTo(didPickImage)
        }
    }
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        anniversariesTableView.register(UINib(nibName: "AnniversaryTableViewCell", bundle: nil), forCellReuseIdentifier: "anniversary table view cell")
        anniversariesTableView.dataSource = self
        anniversariesTableView.delegate = self
        anniversariesTableView.tableFooterView = UIView()

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        placeNameTextView.delegate = self

        
        if let placeImageUrlString = place.imageUrl, let placeImageUrl = URL(string:placeImageUrlString) {
            placeImageView.kf.setImage(with: placeImageUrl)
        }
        placeNameTextView.text = place.name
        
        placeNameTextView.isUserInteractionEnabled = false
        placeNameTextView.addDoneCancelButtons(doneTitle: "Done", cancelTitle: "Cancel", target: self, doneSelector: #selector(PlaceDetailViewController.placeNameTextViewDoneAction(sender:)), cancelSelector: #selector(PlaceDetailViewController.placeNameTextViewCancelAction(sender:)))
        
        //showOnMapButtonAction(UIButton())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adustAnniversariesTableViewHeight(animated: false)
        placeNameTextViewHeightConstraint.constant = adjustUITextViewHeight(placeNameTextView)
    }
    
    //MARK: - IBActions
    @IBAction func updatePlaceImageButtonAction(_ sender: UIButton) {
        let imageSourceAlert = UIAlertController(title: "Image Source", message: "Please select place image source", preferredStyle: .actionSheet)
        imageSourceAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
            self.checkCameraAvilability()
        }))
        imageSourceAlert.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (_) in
            self.openPhotos()
        }))
        imageSourceAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let imageSourceAlertPopover = imageSourceAlert.popoverPresentationController {
            imageSourceAlertPopover.sourceView = self.placeImageView
            imageSourceAlertPopover.sourceRect = self.placeImageView.frame
        }
        DispatchQueue.main.async {
            self.present(imageSourceAlert, animated: true)
        }
    }
    
    @IBAction func editNameButtonAction(_ sender: UIButton) {
        placeNameTextView.isUserInteractionEnabled = true
        placeNameTextView.becomeFirstResponder()
    }
    
    @IBAction func showOnMapButtonAction(_ sender: UIButton) {
        if let placeLocation = place.location, let latitude = placeLocation.first, let longitude = placeLocation.last {
            let placeLocationVC = storyboard?.instantiateViewController(withIdentifier: "place location vc") as! PlaceLocationViewController
            placeLocationVC.placeLocationLatitude = latitude
            placeLocationVC.placeLocationLongitude = longitude
            placeLocationVC.placeName = place.name
            placeLocationVC.delegate = self
            let placeLocationNav = UINavigationController(rootViewController: placeLocationVC)
            present(placeLocationNav, animated: true)
        }
    }
    
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    //MARK: - Selectors
    @objc private func placeNameTextViewDoneAction(sender: Any) {
        self.view.endEditing(true)
        placeNameTextView.isUserInteractionEnabled = false
        guard let newName = placeNameTextView.text else {return}
        guard !newName.isEmpty else {return}
        place.name = newName
        updatePlace(place) { (updated) in
            if !updated {
                self.placeNameTextView.text = self.oldPlaceName
            }
            else {
                self.delegate?.didEditPlace(at: self.placeIndex)
            }
        }
    }
    
    @objc private func placeNameTextViewCancelAction(sender: Any) {
        self.view.endEditing(true)
        placeNameTextView.text = oldPlaceName
        placeNameTextView.isUserInteractionEnabled = false
        placeNameTextViewHeightConstraint.constant = adjustUITextViewHeight(placeNameTextView)
    }
    
    //MARK: - Custom Functions
    func checkCameraAvilability() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            Helper.alert(title: "Camera", message: "Camera is not available!", actionTitle: "OK", presenter: self, action: nil)
            return
        }
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .denied, .restricted:
            Helper.alert(title: "Camera Access!", message: "camera access is restricted, you can change that in device Settings.", actionTitle: "OK", presenter: self, action: nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {self.openCamera()}
            }
        default:
            openCamera()
        }
    }
    
    func openCamera() {
        imagePicker.sourceType = .camera
        imagePicker.cameraDevice = .rear
        DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true)
        }
    }
    
    func openPhotos() {
        imagePicker.sourceType = .photoLibrary
        DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true)
        }
    }
    
    private func adustAnniversariesTableViewHeight(animated: Bool) {
        anniversariesTableView.sizeToFit()
        anniversariesTableViewHeightConstraint.constant = anniversariesTableView.contentSize.height
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func adjustUITextViewHeight(_ textView : UITextView) -> CGFloat {
        textView.frame.size = textView.contentSize
        return textView.frame.height
    }
    
    func didPickImageIsSetTo(_ newValue: Bool) {
        if newValue {
            // upload new image and update database
            upload(image: placeImageView.image!, placeId: place.id) { (newImageUrlString) in
                self.didPickImage = false
                if let newImageUrlString = newImageUrlString {
                    self.place.imageUrl = newImageUrlString
                    self.updatePlace(self.place) { updated in
                        if updated {
                            self.delegate?.didEditPlace(at: self.placeIndex)
                        }
                    }
                }
                else {
                    self.placeImageView.image = self.oldPlaceImage
                }
            }
        }
    }
    
    private func scrollToCursorForTextView(textView: UITextView) {
        guard let startOfRange = textView.selectedTextRange?.start else { return }
        var cursorRect = textView.caretRect(for: startOfRange)
        cursorRect = scrollView.convert(cursorRect, from: textView)
        if !rectVisible(rect: cursorRect) {
            cursorRect.size.height += 8
            scrollView.scrollRectToVisible(cursorRect, animated: true)
        }
    }

    private func rectVisible(rect: CGRect) -> Bool {
        var visibleRect = CGRect()
        visibleRect.origin = scrollView.contentOffset
        visibleRect.origin.y += scrollView.contentInset.top
        visibleRect.size = scrollView.bounds.size
        visibleRect.size.height -= scrollView.contentInset.top + scrollView.contentInset.bottom
        return visibleRect.contains(rect)
    }
    
    func upload(image:UIImage, placeId:String, completion: @escaping (String?) -> Void) {
        FirebaseManager.uploadImage(image, placeId: placeId) { (newImageUrlString) in
            DispatchQueue.main.async {
                completion(newImageUrlString)
            }
        }
    }
    
    func updatePlace(_ place:Place, completion: @escaping (Bool) -> Void) {
        FirebaseManager.editPlace(place) { (edited) in
            DispatchQueue.main.async {
                completion(edited)
            }
        }
    }
    
    private func deletePlaceAnniversary(at:Int) {
        guard let anniversaryToDelete = place?.anniversaries?.remove(at: at) else {return}
        updatePlace(place) { (updated) in
            if updated {
                self.anniversariesTableView.deleteRows(at: [IndexPath(row: at + 1, section: 0)], with: .automatic)
                self.delegate?.didEditPlace(at: self.placeIndex)
            }
            else {
                self.place?.anniversaries?.insert(anniversaryToDelete, at: at + 1)
            }
        }
    }

}

extension PlaceDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let placeAnniversariesCount = place?.anniversaries?.count {
            return placeAnniversariesCount + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "anniversary table view cell") as! AnniversaryTableViewCell
        if indexPath.row == 0 {
            cell.textLabel?.text = "Add Anniversary"
            cell.textLabel?.textColor = UIColor.systemBlue
        }
        else {
            cell.textLabel?.text = place?.anniversaries?[indexPath.row - 1]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let placeAnniversaryVC = storyboard?.instantiateViewController(withIdentifier: "place anniversary vc") as! PlaceAnniversaryViewController
            placeAnniversaryVC.delegate = self
            let placeAnniversaryNav = UINavigationController(rootViewController: placeAnniversaryVC)
            present(placeAnniversaryNav, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Anniversaries"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.row != 0 
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            deletePlaceAnniversary(at: indexPath.row - 1)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        anniversariesTableViewRowHeight
    }
    
    
}

extension PlaceDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeNameTextViewHeightConstraint.constant = adjustUITextViewHeight(textView)
        scrollToCursorForTextView(textView: textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        oldPlaceName = textView.text
    }
    
}

extension PlaceDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self.placeImageView.image = editedImage
                self.didPickImage = true
            }
            else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.placeImageView.image = originalImage
                self.didPickImage = true
            }
        }
    }
}


extension PlaceDetailViewController: PlaceAnniversaryDelegate {
    func didAdd(anniversary: String) {
        place.anniversaries.append(anniversary)
        anniversariesTableView.reloadData()
        updatePlace(place) { (updated) in
            self.adustAnniversariesTableViewHeight(animated: true)
            if updated {
                self.anniversariesTableView.reloadData()
                self.delegate?.didEditPlace(at: self.placeIndex)
            }
            else {
                self.place.anniversaries.removeLast()
                self.anniversariesTableView.reloadData()
            }
        }
    }
}

extension PlaceDetailViewController: PlaceLocationDelegate {
    func didUpdatePlaceLocation(latitude: Double, longitude: Double) {
        place.location = [latitude, longitude]
        updatePlace(place) { updated in
            if updated {
                self.delegate?.didEditPlace(at: self.placeIndex)
            }
        }

    }
}
