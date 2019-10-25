//
//  PlaceLocationViewController.swift
//  Places Anniversaries
//
//  Created by Sameh Salama on 10/23/19.
//  Copyright © 2019 Sameh Salama. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

@objc protocol PlaceLocationDelegate {
    @objc optional func didUpdatePlaceLocation(latitude:Double, longitude:Double)
    @objc optional func didCancelUpdatingPlaceLocation()
}

/// Responsible for managing a view that  views or updates Place location
class PlaceLocationViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var placeMapView: MKMapView!
    
    // MARK: - Properties
    var placeLocationLatitude:Double!
    var placeLocationLongitude:Double!
    var placeLocation: CLLocation! {
        didSet {
            placeLocationLatitude = placeLocation.coordinate.latitude
            placeLocationLongitude = placeLocation.coordinate.longitude
        }
    }
    var placeName:String!
    var delegate: PlaceLocationDelegate? = nil
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeMapView.delegate = self
        
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PlaceLocationViewController.doneBarButtonItemAction(_:)))
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PlaceLocationViewController.cancelBarButtonItemAction(_:)))
        navigationItem.leftBarButtonItem = cancelBarButtonItem
        
        if placeLocationLatitude != nil && placeLocationLongitude != nil {
            placeLocation = CLLocation(latitude: placeLocationLatitude!, longitude: placeLocationLongitude!)
        }
        if let placeLocation = placeLocation {
            let viewRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: placeLocation.coordinate.latitude, longitude: placeLocation.coordinate.longitude), latitudinalMeters: 2000000, longitudinalMeters: 2000000)
            placeMapView.setRegion(viewRegion, animated: false)
            addAnnotation(coordinate: placeLocation.coordinate)
        }
    }
    
    // MARK: - Selectors
    @objc private func doneBarButtonItemAction(_ sender: UIBarButtonItem) {
        dismiss(animated: false) {
            self.delegate?.didUpdatePlaceLocation?(latitude: self.placeLocation.coordinate.latitude, longitude: self.placeLocation.coordinate.longitude)
        }
    }
    
    @objc private func cancelBarButtonItemAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {
            self.delegate?.didCancelUpdatingPlaceLocation?()
        }
    }

    // MARK: - Custom Functions
    private func addAnnotation(coordinate:CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.title = placeName
        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        placeMapView.addAnnotation(annotation)
    }
}

extension PlaceLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        addAnnotation(coordinate: mapView.centerCoordinate)
        placeLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
    }
    
}
