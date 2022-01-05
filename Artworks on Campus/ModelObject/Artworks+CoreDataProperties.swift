//
//  Artworks+CoreDataProperties.swift
//  Artworks on Campus
//
//  Created by Camilo Pinzon on 01/05/19.
//
//

import Foundation
import CoreData


extension Artworks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artworks> {
        return NSFetchRequest<Artworks>(entityName: "Artworks")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var artist: String?
    @NSManaged public var yearOfWork: String?
    @NSManaged public var information: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var location: String?
    @NSManaged public var locationNotes: String?
    @NSManaged public var fileName: String?
    @NSManaged public var lastModified: String?
    @NSManaged public var enabled: Bool
    @NSManaged public var distance: Double

}
