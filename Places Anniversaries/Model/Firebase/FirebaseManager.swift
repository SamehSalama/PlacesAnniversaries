//
//  FirestoreManager.swift
//  Places Anniversaries
//
//  Created by Sameh Salama on 10/22/19.
//  Copyright © 2019 Sameh Salama. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD

/// Responsible for connecting to Firebase to add or retrieve data
class FirebaseManager {
    
    /// places collection in Firebase cloud store
    static private let placesCollection: String = "places"
    /// Firebase cloud store database reference
    static private var db = Firestore.firestore()
    /// Firebase Storage
    static private let storage = Storage.storage()
    /// Firebase storage reference with full path to places images folder
    static private let storageRef = storage.reference().child("placesImages")
    /// number of place objects to be retrieved per request
    static var pageSize:Int = 20
    
    
    /// signs in to Firebase anonymously
    /// - Parameter completion: completion closure with optoinal user uid returning from Firebase
    class func anonymouslySignInToFirebase(completion: @escaping (String?) -> Void) {
        showHUD()
        Auth.auth().signInAnonymously() { (authResult, error) in
            dismissHud()
            if let error = error {
                print("Firebase anonymous sign in error \(error.localizedDescription)")
                completion(error.localizedDescription)
            }
            if let userUid = authResult?.user.uid {
                print("Firebase user uid \(userUid)")
                completion(userUid)
            }
        }
    }
    
    /// Shows loading HUD
    class private func showHUD() {
        SVProgressHUD.show()
    }
    
    /// Dismisses loading HUD
    class private func dismissHud() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
    
    /// Retrieves places objects from Firestore
    /// - Parameter lastPlaceName: if nil, it gets firestore documents starting from first object ordered by name, else it retrieves documents after last object retrieved, this is useful for pagination
    /// - Parameter completion: completion closure with retrieved places
    class func getPlaces(lastPlaceName: String?, completion: @escaping ([Place]?, Int?) -> Void) {
        showHUD()
        var query: Query!
        if lastPlaceName == nil {
            query = db.collection(placesCollection).order(by: "name").limit(to: pageSize)
        }
        else {
            query = db.collection(placesCollection).order(by: "name").start(after: [lastPlaceName!]).limit(to: pageSize)
        }
        query.getDocuments { (snapshot, error) in
            dismissHud()
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, snapshot?.count)
            }
            else {
                var places:[Place] = []
                for i in snapshot!.documents {
                    if let place = Parser.parse(placeDictionary: i.data(), withId: i.documentID) {
                        places.append(place)
                    }
                }
                completion(places, snapshot?.count)
            }
        }
    }
    
    /// Adds new place object to Firebase cloud store, and replaces old places in cloud store if place id exists
    /// - Parameter place: plac object to be added
    /// - Parameter completion: completion closure with document id
    class func addPlace(_ place:Place, completion: @escaping (String?) -> Void) {
        showHUD()
        var ref: DocumentReference? = nil
        ref = db.collection(placesCollection).addDocument(data: place.addNewPlaceDictionary()) { error in
            dismissHud()
            if let error = error {
                print("Error adding document: \(error)")
                completion(nil)
            } else {
                if let documentId = ref?.documentID {
                    completion(documentId)
                }
                else {
                    completion(nil)
                }
            }
        }
    }
    
    /// Delete a place from Firebase cloud store
    /// - Parameter id: place id
    /// - Parameter completion: completion closure with boolean indicating whether request succeeded
    class func deletePlace(_ id:String, completion: @escaping (Bool) -> Void) {
        showHUD()
        db.collection(placesCollection).document(id).delete() { error in
            dismissHud()
            if let error = error {
                print("Error removing document: \(error)")
                completion(false)
            } else {
                self.deletePlaceImage(id) { _ in }
                completion(true)
            }
        }
    }
    
    /// Edits existing place in Firebase cloud store
    /// - Parameter place: place object to be updated
    /// - Parameter completion: completion closure with a boolean indicating whether request succeeded
    class func editPlace(_ place:Place, completion: @escaping (Bool) -> Void) {
        showHUD()
        db.collection(placesCollection).document(place.id).setData(place.addNewPlaceDictionary()) { error in
            dismissHud()
            if let error = error {
                print("Error writing document: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    /// Uploads an image to Firebase storage
    /// - Parameter image: image to be uploaded
    /// - Parameter placeId: place object id, to be used as image name
    /// - Parameter completion: completion closure with optional uploaded image download url
    class func uploadImage(_ image:UIImage, placeId:String, completion: @escaping (String?) -> Void) {
        showHUD()
        let imageRef = storageRef.child("\(placeId).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            dismissHud()
            if let error = error {
                print("Error uploading image: \(error)")
                completion(nil)
            }
          imageRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                completion(nil)
              return
            }
            completion(downloadURL.absoluteString)
          }
        }
    }
    
    /// Deletes image from Firebase Storage, can be called upon succeful place deletion
    /// - Parameter imageName: image name that is to be deleted
    /// - Parameter completion: completion closure with a boolean indicating whether request succeeded
    class func deletePlaceImage(_ imageName:String, completion: @escaping (Bool) -> Void) {
        let imageRef = storageRef.child("\(imageName).jpg")
        imageRef.delete { error in
          if let error = error {
            print("Error deleting image: \(error)")
            completion(false)
          } else {
            completion(true)
          }
        }
    }
    
    
    
}

