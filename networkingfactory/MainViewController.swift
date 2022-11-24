//
//  ViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 23/11/22.
//

import UIKit

class MainViewController: UIViewController {
    var testImage = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        if let url = URL(string: "https://store.storeimages.cdn-apple.com/4982/" +
                         "as-images.apple.com/is/iphone14promax-digitalmat-gallery-3-202209?" +
                         "wid=728&hei=666&fmt=png-alpha&.v=1663346233350") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.testImage.image = UIImage(data: data)
                }
                print(response!.description)
            }
            task.resume()
        }
        view.addSubview(testImage)
        let testNavButton = UIBarButtonItem(barButtonSystemItem: .fastForward,
                                            target: self, action: #selector(nextPage))
        navigationItem.rightBarButtonItem = testNavButton
        configureGeneralConstraints()
    }
    @objc func nextPage() {
        let secondScreen = SecondViewController()
        navigationController?.pushViewController(secondScreen, animated: true)
    }
}

extension MainViewController {
    func configureGeneralConstraints() {
        testImage.translatesAutoresizingMaskIntoConstraints = false
        testImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 390).isActive = true
        testImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        testImage.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: -50).isActive = true
        testImage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 50).isActive = true
    }
}
