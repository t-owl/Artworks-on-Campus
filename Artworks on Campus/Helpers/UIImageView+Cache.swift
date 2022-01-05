//
//  UIImageView+Cache.swift
//  Artworks on Campus
//
//  Created by Camilo Pinzon on 01/05/19.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func cacheImage(urlString: String){
        if let urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let url = URL(string: urlString)
            
            image = nil
            
            if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
                self.image = imageFromCache
                return
            }
            
            URLSession.shared.dataTask(with: url!) {
                data, response, error in
                if data != nil {
                    DispatchQueue.main.async {
                        let imageToCache = UIImage(data: data!)
                        imageCache.setObject(imageToCache!, forKey: urlString as AnyObject)
                        self.image = imageToCache
                    }
                }
                }.resume()
        }
    }
}
