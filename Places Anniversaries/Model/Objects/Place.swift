//
//  Place.swift
//  Places Anniversaries
//
//  Created by Sameh Salama on 10/22/19.
//  Copyright © 2019 Sameh Salama. All rights reserved.
//

import Foundation
import Firebase

class Place: Codable {
    
    var id:String!
    var name:String!
    var location:[Double]!
    var imageUrl:String!
    var anniversaries:[String]!
    
//    required init() {
//    }
//
//    required init(from decoder:Decoder) {
//        do {
//            let values = try decoder.container(keyedBy: CodingKeys.self)
//            id = try? values.decode(String.self, forKey: .id)
//            name = try? values.decode(String.self, forKey: .name)
//            location = try? values.decode([Double].self, forKey: .location)
//            imageUrl = try? values.decode(String.self, forKey: .imageUrl)
//            anniversaries = try? values.decode([String].self, forKey: .anniversaries)
//        }
//        catch {
//            print("Place decoding error: \(error)")
//        }
//    }
    
}

//extension Place {
//    private enum CodingKeys:String, CodingKey {
//        case id = "id"
//        case name = "name"
//        case location = "location"
//        case imageUrl = "image_url"
//        case anniversaries = "anniversaries"
//    }
//}


extension Place {
    func addNewPlaceDictionary() -> [String:Any] {
        ["name": name!,
         "location":GeoPoint(latitude: location[0], longitude: location[1]),
         "imageUrl":imageUrl ?? "",
         "anniversaries":anniversaries!
        ]
    }
}


//class Geopoint {
//    var longitude: Double!
//    var latitude: Double!
//}

//class Geopoint : Codable {
//    
//    var longitude: Double!
//    var latitude: Double!
//    
//    
//    enum CodingKeys: String, CodingKey {
//        case longitude, latitude
//    }
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        latitude = try? values.decode(Double.self, forKey: .latitude)
//        longitude = try? values.decode(Double.self, forKey: .longitude)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(latitude, forKey: .latitude)
//        try container.encode(longitude, forKey: .longitude)
//    }
//}
