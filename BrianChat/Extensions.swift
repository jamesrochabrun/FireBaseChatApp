//
//  Extensions.swift
//  BrianChat
//
//  Created by James Rochabrun on 1/25/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import UIKit
import Foundation

let imageCache = NSCache<NSString, UIImage>()

extension  UIImageView {
    
    func loadImageUsingCacheWithURLString(_ URLString: String) {
        
        //avoiding flashing/ lag 
        self.image = nil
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: NSString(string: URLString)) {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        if  let url = URL(string: URLString) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil {
                    print("ERROR LOADING IMAGES FROM URL: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    //caching an image
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            imageCache.setObject(downloadedImage, forKey: NSString(string: URLString))
                            self.image = downloadedImage
                        }
                    }
                }
            }).resume()
        }
    }
}

extension NSString {
    
    static func fromDateInSeconds(_ seconds: Double) -> String {
        let timeStampDate = NSDate(timeIntervalSince1970: seconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        return dateFormatter.string(from: timeStampDate as Date)
    }
}









