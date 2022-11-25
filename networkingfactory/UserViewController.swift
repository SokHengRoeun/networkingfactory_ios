//
//  UserViewController.swift
//  networkingfactory
//
//  Created by SokHeng on 25/11/22.
//

import UIKit

class UserViewController: UIViewController {
    var userObj = UserContainerObject(id: "", email: "", first_name: "", last_name: "", token: "")
    var vStackContainer: UIStackView = {
        let myStack = UIStackView()
        myStack.translatesAutoresizingMaskIntoConstraints = false
        myStack.axis = .vertical
        myStack.spacing = 5
        return myStack
    }()
    var idTitle: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "ID :"
        myLabel.font = UIFont.boldSystemFont(ofSize: 17)
        return myLabel
    }()
    var idBody = UILabel()
    var userNameTitle: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Full name :"
        myLabel.font = UIFont.boldSystemFont(ofSize: 17)
        return myLabel
    }()
    var userNameBody = UILabel()
    var emailTitle: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Email :"
        myLabel.font = UIFont.boldSystemFont(ofSize: 17)
        return myLabel
    }()
    var emailBody = UILabel()
    var tokenTitle: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Token :"
        myLabel.font = UIFont.boldSystemFont(ofSize: 17)
        return myLabel
    }()
    var tokenBody = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGeneralUI()
        configureGeneralConstraints()
    }
    @objc func signoutOnclick() {
        showAlertBox(title: "Are you sure?",
                     message: "You are about to signout of your account.",
                     firstButtonAction: nil,
                     firstButtonText: "Cancel",
                     firstButtonStyle: .cancel,
                     secondButtonAction: { _ in self.navigationController?.popViewController(animated: true) },
                     secondButtonText: "Sign out",
                     secondButtonStyle: .destructive)
    }
}

extension UserViewController {
    func configureGeneralUI() {
        view.backgroundColor = UIColor.white
        title = "Welcome"
        let signoutButton = UIBarButtonItem(title: "sign out",
                                            style: .plain,
                                            target: self,
                                            action: #selector(signoutOnclick))
        signoutButton.tintColor = UIColor.red
        self.navigationItem.setLeftBarButton(signoutButton, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        idBody.text = userObj.id
        userNameBody.text = "\(userObj.first_name) \(userObj.last_name)"
        emailBody.text = userObj.email
        tokenBody.text = userObj.token
        view.addSubview(vStackContainer)
        vStackContainer.addArrangedSubview(idTitle)
        vStackContainer.addArrangedSubview(idBody)
        vStackContainer.addArrangedSubview(userNameTitle)
        vStackContainer.addArrangedSubview(userNameBody)
        vStackContainer.addArrangedSubview(emailTitle)
        vStackContainer.addArrangedSubview(emailBody)
        vStackContainer.addArrangedSubview(tokenTitle)
        vStackContainer.addArrangedSubview(tokenBody)
        idBody.textColor = UIColor.link
        userNameBody.textColor = UIColor.link
        emailBody.textColor = UIColor.link
        tokenBody.textColor = UIColor.link
        tokenBody.numberOfLines = 0
    }
    func configureGeneralConstraints() {
        vStackContainer.translatesAutoresizingMaskIntoConstraints = false
        vStackContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        vStackContainer.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                               constant: -20).isActive = true
        vStackContainer.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                              constant: 20).isActive = true
    }
}
