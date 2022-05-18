//
//  ViewController.swift
//  ScrolView
//
//  Created by Игорь Островский on 01.05.2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var image:UIImageView!
    @IBOutlet weak var label:UILabel!
    
    var trackTitle = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.image = UIImage(named: trackTitle)
        label.text = trackTitle
        label.numberOfLines = 0 
        
    }
}

