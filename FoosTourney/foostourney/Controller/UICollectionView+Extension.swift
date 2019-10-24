//
//  UICollectionView+Extension.swift
//  foostourney
//
//  Created by Mahesh Chauhan on 10/10/19.
//  Copyright © 2019 Mahesh Chauhan. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {

    // Extension method to set a empty message to UICollectionView.
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? .white : .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    // Extension method to restore empty message to UICollectionView.
    func restore() {
        self.backgroundView = nil
    }
    
}
