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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconImage)
        contentView.addSubview(downIconImage)
        contentView.addSubview(fileNameLabel)
        contentView.addSubview(sizeNameLabel)
        configureConstrants()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
    }
}
