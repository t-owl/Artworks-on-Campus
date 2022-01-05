//
//  GroupedArtwork.swift
//  Artworks on Campus
//
//  Created by Camilo Pinzon on 01/05/19.
//

import UIKit
import CoreLocation

class GroupedArtworks: NSObject {
    var artworks = [Artworks]()
    var locationName = ""
    var location = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
}
