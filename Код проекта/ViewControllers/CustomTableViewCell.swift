//
//  CustomTableViewCell.swift
//  ScrolView
//
//  Created by Игорь Островский on 03.05.2022.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var imageOfPlace:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var locationLabel:UILabel!
    @IBOutlet weak var typelabel:UILabel!
    @IBOutlet var cosmosView:CosmosView!{
        didSet{
            cosmosView.settings.updateOnTouch = false
        }
    }
    


}
