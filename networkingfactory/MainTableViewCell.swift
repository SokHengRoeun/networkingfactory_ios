//
//  MainTableViewCell.swift
//  networkingfactory
//
//  Created by SokHeng on 30/11/22.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    var fileNameLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Name"
        myLabel.font = .boldSystemFont(ofSize: 16)
        return myLabel
    }()
    var sizeNameLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.text = "Category"
        myLabel.font = .systemFont(ofSize: 14)
        return myLabel
    }()
    var iconImage: UIImageView = {
        let myImage = UIImageView()
        let imageSize: CGFloat = 40
        myImage.translatesAutoresizingMaskIntoConstraints = false
        myImage.contentMode = .scaleAspectFit
        myImage.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        return myImage
    }()
    var downIconImage: UIImageView = {
        let myImage = UIImageView()
        let imageSize: CGFloat = 25
        myImage.translatesAutoresizingMaskIntoConstraints = false
        myImage.contentMode = .scaleAspectFit
        myImage.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        myImage.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        return myImage
    }()
    var spinIndicator = UIActivityIndicatorView()
    var loadingProgressBar = UIProgressView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconImage)
        contentView.addSubview(downIconImage)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(loadingProgressBar)
        contentView.addSubview(spinIndicator)
        loadingProgressBar.tintColor = UIColor.green
        contentView.addSubview(sizeNameLabel)
        configureConstrants()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func setToCompleted(fileName: String) {
        // this is the fastest way to set a processing cell to completed
        // this function only have ability to mark processing as completed
        let iconManager = IconManager.shared
        self.fileNameLabel.text = fileName
        self.iconImage.image = iconManager.iconFileType(fileName: fileName)
        self.sizeNameLabel.text = "file downloaded"
        self.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
        setAsProgressing(false)
    }
    func setAsProgressing(_ setActive: Bool) {
        // if setActive == true. Set cell as Processing which show processing bar
        // if setActive == false. Set cell as Completed which hide processing bar
        self.sizeNameLabel.isHidden = setActive
        self.downIconImage.isHidden = setActive
        self.loadingProgressBar.isHidden = !setActive
        self.spinIndicator.isHidden = !setActive
        if setActive {
            self.spinIndicator.startAnimating()
        }
    }
}

extension MainTableViewCell {
    func configureConstrants() {
        iconImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        iconImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        fileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        fileNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        fileNameLabel.leftAnchor.constraint(equalTo: iconImage.rightAnchor, constant: 10).isActive = true
        fileNameLabel.rightAnchor.constraint(equalTo: downIconImage.leftAnchor, constant: -10).isActive = true
        sizeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeNameLabel.topAnchor.constraint(equalTo: fileNameLabel.bottomAnchor).isActive = true
        sizeNameLabel.leftAnchor.constraint(equalTo: iconImage.rightAnchor, constant: 10).isActive = true
        sizeNameLabel.rightAnchor.constraint(equalTo: downIconImage.leftAnchor, constant: -10).isActive = true
        downIconImage.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        downIconImage.centerYAnchor.constraint(equalTo: iconImage.centerYAnchor).isActive = true
        loadingProgressBar.translatesAutoresizingMaskIntoConstraints = false
        loadingProgressBar.centerYAnchor.constraint(equalTo: sizeNameLabel.centerYAnchor).isActive = true
        loadingProgressBar.leftAnchor.constraint(equalTo: iconImage.rightAnchor, constant: 10).isActive = true
        loadingProgressBar.rightAnchor.constraint(equalTo: downIconImage.leftAnchor, constant: -10).isActive = true
        spinIndicator.absoluteFitToThe(parent: downIconImage,
                                                    padding: 0)
    }
}
