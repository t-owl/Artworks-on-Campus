//
//  NetworkManager.swift
//  Artworks on Campus
//
//  Created by Camilo Pinzon on 01/05/19.
//

import Foundation
class NetworkManager{
    static let shared = NetworkManager()
    static let baseURL:String = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php"
    static let imageBaseURL:String = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artwork_images/"
    func sendRequest(with parameters: [String: String], completion: @escaping ([String: Any]?, Error?) -> Void) {
        let url = NetworkManager.baseURL
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: components.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    completion(nil, error)
                    return
            }
            
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            completion(responseObject, nil)
        }
        task.resume()
    }
}
