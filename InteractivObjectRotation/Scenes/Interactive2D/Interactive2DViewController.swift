//
//  Interactive2DViewController.swift
//  InteractivObjectRotation
//
//  Created by  user on 10.09.2023.
//

import UIKit

final class Interactive2DViewController: UIViewController {

    private var customView = Interactive2DView()

    override func loadView() {
        self.view = customView
    }
  
}
