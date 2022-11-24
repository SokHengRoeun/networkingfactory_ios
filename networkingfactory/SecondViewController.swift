//
//  SecondViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 23/11/22.
//

import UIKit

class SecondViewController: UIViewController {
    var vStackContainer: UIStackView = {
        let myStack = UIStackView()
        myStack.translatesAutoresizingMaskIntoConstraints = false
        myStack.axis = .vertical
        myStack.spacing = 10
        return myStack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second Screen"
        view.backgroundColor = UIColor.white
        view.addSubview(vStackContainer)
    }
}

extension SecondViewController {
    func configureGeneralConstraints() {
        vStackContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        vStackContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        vStackContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        vStackContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
    }
}
