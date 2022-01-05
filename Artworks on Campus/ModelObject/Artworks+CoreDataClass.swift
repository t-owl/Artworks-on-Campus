//
//  Artworks+CoreDataClass.swift
//  Artworks on Campus
//
//  Created by Camilo Pinzon on 01/05/19.
//
//

import Foundation
import CoreData
import UIKit
import CoreLocation

@objc(Artworks)
public class Artworks: NSManagedObject {

    static func getArtwork(with id: String) -> Artworks?{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let fetchRequest : NSFetchRequest<Artworks> = Artworks.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            let fetchedResults = try context.fetch(fetchRequest) 
            if let artwork = fetchedResults.first {
                return artwork
            }
        }
        catch {
            print ("fetch task failed", error)
        }
        return nil
    }
    
    static func getAllArtworks() -> [Artworks]? {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let fetchRequest : NSFetchRequest<Artworks> = Artworks.fetchRequest()
            let fetchedResults = try context.fetch(fetchRequest)
            return fetchedResults
            
        }
        catch {
            print ("fetch task failed", error)
        }
        return nil
    }

    static func getAllArtworksInLocationSortOrder(with coordinate: CLLocationCoordinate2D) -> [Artworks]? {
        let coordinateLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if var artworks = Artworks.getAllArtworks() {
            for artwork in artworks {
                let distanceInMeters = coordinateLocation.distance(from: CLLocation(latitude: artwork.lat, longitude: artwork.long))
                artwork.distance = distanceInMeters
            }
            artworks = artworks.sorted(by: { $0.distance < $1.distance })
            return artworks
        }

        return nil
    }
    
    static func getAllArtworks(withContaining stringToSearch:String) -> [Artworks]? {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let fetchRequest : NSFetchRequest<Artworks> = Artworks.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title contains[c] %@ OR locationNotes contains[c] %@ OR artist contains[c] %@", stringToSearch, stringToSearch, stringToSearch)
            let fetchedResults = try context.fetch(fetchRequest)
            return fetchedResults
            
        }
        catch {
            print ("fetch task failed", error)
        }
        return nil
    }
    
    static func getAllArtworksInLocationSortOrder(with coordinate: CLLocationCoordinate2D, text: String) -> [Artworks]? {
        let coordinateLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if var artworks = Artworks.getAllArtworks(withContaining: text) {
            for artwork in artworks {
                let distanceInMeters = coordinateLocation.distance(from: CLLocation(latitude: artwork.lat, longitude: artwork.long))
                artwork.distance = distanceInMeters
            }
            artworks = artworks.sorted(by: { $0.distance < $1.distance })
            return artworks
        }
        
        return nil
    }
}
