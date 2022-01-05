//
//  DataSyncManager.swift
//  Artworks on Campus
//
//  Created by Camilo Pinzon on 01/05/19.
//

import UIKit
import CoreData

class DataSyncManager: NSObject {
    static let shared = DataSyncManager()
    static let dataUpdatedNotification = "DataUpdatedNotification"
    func fetchAndStoreData() {
        var queryParam = ["class":"campus_artworks"]
        if let lastUpdate = DataSyncManager.shared.fetchLastUpdateDate() {
            queryParam["lastUpdate"] = lastUpdate
        }
        NetworkManager.shared.sendRequest(with: queryParam) { (data, error) in
            if error == nil {
                //save last update
                if let data = data, let artworksData = data["campus_artworks"] as? [[String: String]] {
                    DispatchQueue.main.async {
                        self.saveData(artworksData)
                        self.saveLastUpdateDate()
                        NotificationCenter.default.post(name: Notification.Name(DataSyncManager.dataUpdatedNotification), object: nil)
                    }
                }
            } else {
                print("error")
            }
        }
    }
    
    func saveData(_ data:[[String: String]]) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        for obj in data {
            let entity = NSEntityDescription.entity(forEntityName: "Artworks", in: context)!
            if let id = obj["id"], let artwork = Artworks.getArtwork(with: id) ?? NSManagedObject(entity: entity, insertInto: context) as? Artworks {
                artwork.id = obj["id"]
                artwork.title = obj["title"]
                artwork.artist = obj["artist"]
                artwork.yearOfWork = obj["yearOfWork"]
                artwork.information = obj["Information"]
                artwork.lat = Double(obj["lat"] ?? "0.0") ?? 0.0
                artwork.long = Double(obj["long"] ?? "0.0") ?? 0.0
                artwork.location = obj["location"]
                artwork.locationNotes = obj["locationNotes"]
                artwork.fileName = obj["fileName"]
                artwork.lastModified = obj["lastModified"]
                artwork.enabled = obj["enabled"] == "0" ? false : true
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

    }
    
    func saveLastUpdateDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        UserDefaults.standard.set(dateFormatter.string(from: Date()), forKey: "lastUpdate")
    }
    
    func fetchLastUpdateDate() -> String? {
        if let lastUpdate = UserDefaults.standard.string(forKey: "lastUpdate") {
            return lastUpdate
        }
        return nil
    }
}

