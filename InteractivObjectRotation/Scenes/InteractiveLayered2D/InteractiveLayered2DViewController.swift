//
//  InteractiveLayered2DViewController.swift
//  InteractivObjectRotation
//
//  Created by  user on 10.09.2023.
//

import UIKit

final class Interactive2DLayeredViewController: UIViewController {
  
    private var customView = InteractiveLayered2DView()

    override func loadView() {
        self.view = customView
    }
  
}
