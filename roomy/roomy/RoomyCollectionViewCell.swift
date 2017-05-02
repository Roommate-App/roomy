//
//  RoomyCollectionViewCell.swift
//  roomy
//
//  Created by Ryan Liszewski on 4/11/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import IBAnimatable

class RoomyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var roomyUserNameLabel: UILabel!
    
    @IBOutlet weak var roomyPosterView: AnimatableImageView!
    @IBOutlet weak var roomyBadgeView: AnimatableImageView!
}
