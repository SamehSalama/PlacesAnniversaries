//
//  Parser.swift
//  Places Anniversaries
//
//  Created by Sameh Salama on 10/22/19.
//  Copyright © 2019 Sameh Salama. All rights reserved.
//

import Foundation
import Firebase

/// Parses Firebase response to Swift objects
class Parser {
    
    /// converts response to Data
    /// - Parameter json: JSON response
    class func data(from json:Any?) -> Data? {
        guard json != nil else {return nil}
        do {
            return try JSONSerialization.data(withJSONObject: json!, options: .fragmentsAllowed)
        }
        catch let error {
            print(error)
            return nil
        }
    }
    
    /// parses place response
    /// - Parameter placeData: place response
    /// - Parameter withId: place id
    /// - Parameter latitude: place latitude
    /// - Parameter longitude: place longitude
    class func parse(placeData:Any?, withId:String, latitude:Double, longitude:Double) -> Place? {
        do {
            guard let data = self.data(from: placeData) else {return nil}
            let place = try JSONDecoder().decode(Place.self, from: data)
            place.id = withId
            place.location = [latitude, longitude]
            return place
        }
        catch let error {
            print("parsing place data error: \(error)")
            return nil
        }
    }
    
    
    /// parses Firebase place response
    /// - Parameter placeDictionary: place response from Firebase
    /// - Parameter withId: place id, AKA document id
    class func parse(placeDictionary:[String:Any], withId:String) -> Place? {
        if let name =  placeDictionary["name"] as? String,
        let imageUrl = placeDictionary["imageUrl"] as? String,
        let location = placeDictionary["location"] as? GeoPoint,
            let anniversaries = placeDictionary["anniversaries"] as? [String] {
            
            let place = Place()
            place.id = withId
            place.name = name
            place.imageUrl = imageUrl
            place.location = [location.latitude, location.longitude]
            place.anniversaries = anniversaries
            return place
        }
        return nil
    }
    

}
