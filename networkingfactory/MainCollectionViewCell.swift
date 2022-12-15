//
//  mainCollectionCellCollectionViewCell.swift
//  networkingfactory
//
//  Created by SokHeng on 28/11/22.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    var mainIcon: UIImageView = {
        let myImage = UIImageView()
        myImage.contentMode = .scaleAspectFit
        myImage.image = UIImage(systemName: "folder.fill")?.withTintColor(UIColor.link,
                                                                          renderingMode: .alwaysOriginal)
        return myImage
    }()
    var folderLabel: UILabel = {
        let myLabel = UILabel()
        myLabel.font = .boldSystemFont(ofSize: 15)
        myLabel.textColor = UIColor.link
        myLabel.textAlignment = .center
        return myLabel
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white
        contentView.hasBorderOutline(outlineColor: UIColor.link.cgColor, outlineWidth: 1, cornerRadius: 13.5)
        contentView.addSubview(mainIcon)
        contentView.addSubview(folderLabel)
        configurateConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configurateConstraints() {
        mainIcon.translatesAutoresizingMaskIntoConstraints = false
        mainIcon.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        mainIcon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        mainIcon.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        mainIcon.heightAnchor.constraint(equalToConstant: 85).isActive = true
        folderLabel.translatesAutoresizingMaskIntoConstraints = false
        folderLabel.topAnchor.constraint(equalTo: mainIcon.bottomAnchor).isActive = true
        folderLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5).isActive = true
        folderLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
    }
}
