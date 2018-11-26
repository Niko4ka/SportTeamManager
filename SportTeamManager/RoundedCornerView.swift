//
//  RoundedCornerView.swift
//  SportTeamManager
//
//  Created by Вероника Данилова on 25/11/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class RoundedCornerView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10.0
        clipsToBounds = true
    }

}
