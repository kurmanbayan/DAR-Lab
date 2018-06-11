//
//  MainViewController.swift
//  Downloadr
//
//  Created by Kurnmanbay Ayan on 6/11/18.
//  Copyright © 2018 Kurmanbay Ayan. All rights reserved.
//

import UIKit

protocol CellDelegate {
    func didTap(_ cell: MainTableViewCell, _ type: Int)
}

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellDelegate {

    func didTap(_ cell: MainTableViewCell, _ type: Int) {
        let indexPath = self.tableView.indexPath(for: cell)!
        let trackUrl = songs[indexPath.row].trackUrl
        
        if (type != 2) {
            self.songs[indexPath.row].opType = type
            Songs.downloadSong(url: trackUrl) { (count) in
                self.songs[indexPath.row].progress = Float(count)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                if (Float(count) == 1.0) {
                    self.songs[indexPath.row].opType = 2
                }
            }
        }
        else {
            Songs.deleteSong(url: trackUrl) { (message) in
                if let message = message {
                    print(message)
                }
                else {
                    self.songs[indexPath.row].opType = 0
                    self.tableView.reloadData()
                }
            }
        }
//        tryToDownload(url: trackUrl)
    }
    
    func tryToDownload(url: String) {
        let url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        if let audioUrl = URL(string: url) {
            
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
            } else {
                
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        getSongs()
    }
    
    var songs: [Songs] = []
    
    func getSongs() {
        Songs.getSongs { (data, message) in
            if let message = message {
                print(message)
            }
            else {
                self.songs = data!
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainId", for: indexPath) as! MainTableViewCell
        cell.artistNameLabel.text = songs[indexPath.row].artist
        cell.songNameLabel.text = songs[indexPath.row].title
        
        let url = songs[indexPath.row].trackUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        if let audioUrl = URL(string: url) {
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                songs[indexPath.row].opType = 2
            }
        }
        
        cell.downloadProgress.setProgress(songs[indexPath.row].progress, animated: true)
        
        cell.checkBtnType(songs[indexPath.row].opType)
        
        cell.delegate = self
        
        return cell
    }
}
