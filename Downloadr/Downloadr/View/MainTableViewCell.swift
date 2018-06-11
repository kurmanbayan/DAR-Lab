//
//  MainTableViewCell.swift
//  Downloadr
//
//  Created by Kurnmanbay Ayan on 6/11/18.
//  Copyright © 2018 Kurmanbay Ayan. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var downloadProgress: UIProgressView!
    
    var delegate: CellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        downloadProgress.setProgress(0, animated: true)
    }
    
    @IBAction func actionBtnPressed(_ sender: UIButton) {
        let actionBtnTitle = actionButton.titleLabel!.text!
        if (actionBtnTitle == "Скачать") {
            delegate?.didTap(self, 1)
        } else {
            delegate?.didTap(self, 2)
        }
    }
    
    func buttonType(title: String, color: UIColor, isEnabled: Bool, isHidden: Bool) {
        actionButton.setTitle(title, for: .normal)
        actionButton.setTitleColor(color, for: .normal)
        actionButton.isEnabled = isEnabled
        downloadProgress.isHidden = isHidden
    }
    
    func checkBtnType(_ opType: Int) {
        switch opType {
        case 0:
            buttonType(title: "Скачать", color: UIColor.red, isEnabled: true, isHidden: true)
        case 1:
            buttonType(title: "Идет загрузка", color: UIColor.blue, isEnabled: false, isHidden: false)
        case 2:
            buttonType(title: "Удалить", color: UIColor.red, isEnabled: true, isHidden: true)
        default:
            break
        }
    }
}
