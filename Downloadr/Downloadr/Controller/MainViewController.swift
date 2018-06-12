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
            DispatchQueue.main.async {
                var state = false
                Songs.downloadSong(trackUrl) { (count) in
                    self.songs[indexPath.row].progress = Float(count)
                    
                    if let mainCell = self.tableView.cellForRow(at: indexPath) as? MainTableViewCell {
                        mainCell.downloadProgress.setProgress(Float(count), animated: false)
                        mainCell.checkBtnType(1)
                    }
                    if !state {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                        state = true
                    }
                    
                    if (Float(count) == 1.0) {
                        self.songs[indexPath.row].opType = 2
                        self.tableView.reloadData()
                    }
                }
            }
        }
        else {
            Songs.deleteSong(trackUrl) { (message) in
                if let message = message {
                    print(message)
                }
                else {
                    self.songs[indexPath.row].opType = 0
                    self.tableView.reloadData()
                }
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
        
        Songs.checkForStorage(songs[indexPath.row].trackUrl) { (result) in
            if result {
                self.songs[indexPath.row].opType = 2
            }
        }
        
        cell.downloadProgress.setProgress(songs[indexPath.row].progress, animated: true)
        
        cell.checkBtnType(songs[indexPath.row].opType)
        
        cell.delegate = self
        
        return cell
    }
}
