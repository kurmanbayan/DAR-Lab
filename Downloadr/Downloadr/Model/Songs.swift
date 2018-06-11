//
//  Songs.swift
//  Downloadr
//
//  Created by Kurnmanbay Ayan on 6/11/18.
//  Copyright © 2018 Kurmanbay Ayan. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

struct Songs: Mappable {
    init?(map: Map) {}
    
    var artist = ""
    var title = ""
    var album = ""
    var trackUrl = ""
    var opType = 0
    var progress: Float = 0.0
    
    mutating func mapping(map: Map) {
        artist <- map["artist"]
        title <- map["title"]
        album <- map["album"]
        trackUrl <- map["url"]
    }
    
    static func getSongs(_ completion: @escaping ([Songs]?, String?) -> Void) {
        let url = "https://vibze.github.io/downloadr-task/tracks.json"
        
        Alamofire.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = value as! [String: Any]
                let data = json["tracks"] as! [[String:Any]]
                completion(data.map { Songs (JSON: $0)! }, nil)
            case .failure(let error):
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    static func downloadSong(url: String, completion: @escaping (Double) -> Void) {
        let url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        if let audioUrl = URL(string: url) {
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)

            Alamofire.request(url).downloadProgress { (progress) in
                completion(progress.fractionCompleted)
                }.responseData { (response) in
                    switch response.result {
                    case .success(let value):
                        do {
                            print(value)
//                            try FileManager.default.moveItem(at: response.result.value, to: destinationUrl)
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
    
    static func deleteSong(url: String, completion: @escaping (String?) -> Void) {
        let url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        if let audioUrl = URL(string: url) {
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            do {
                try FileManager.default.removeItem(at: destinationUrl)
                    completion(nil)
            }
            catch let error as NSError {
                completion(error.localizedDescription)
            }
        }
    }
}
