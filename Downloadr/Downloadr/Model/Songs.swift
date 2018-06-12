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
    
    static func downloadSong(_ url: String, completion: @escaping (Double) -> Void) {
        let url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        if let audioUrl = URL(string: url) {

            let fileUrl = self.getSaveFileUrl(fileName: url)
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            Alamofire.download(audioUrl, to:destination)
                .downloadProgress { (progress) in
                    completion(progress.fractionCompleted)
                }
                .responseData { (data) in
                    print(data)
            }
        }
    }
    
    static func getSaveFileUrl(fileName: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let nameUrl = URL(string: fileName)
        let fileURL = documentsURL.appendingPathComponent((nameUrl?.lastPathComponent)!)
        NSLog(fileURL.absoluteString)
        return fileURL;
    }
    
    static func deleteSong(_ url: String, completion: @escaping (String?) -> Void) {
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
    
    static func checkForStorage(_ url: String, completion: @escaping(Bool) -> Void) {
        let url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        if let audioUrl = URL(string: url) {
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                completion(true)
            }
        }
    }
}
