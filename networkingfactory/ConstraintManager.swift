//
//  ConstraintManager.swift
//  networkingfactory
//
//  Created by SokHeng on 16/12/22.
//

import Foundation
import UIKit

class ConstraintManager {
    static let shared = ConstraintManager()
    enum ChooseSide {
        case toTheTop
        case toTheBottom
        case toTheLeft
        case toTheRight
    }
    func fitToThe(toSide: ChooseSide, padding: CGFloat, child: UIView, parent: UIView) -> UIView {
        let tempObj = child
        tempObj.isAutoResize(false)
        switch toSide {
        case .toTheTop:
            tempObj.topAnchor.constraint(equalTo: parent.topAnchor, constant: padding).isActive = true
        case .toTheBottom:
            tempObj.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -padding).isActive = true
        case .toTheLeft:
            tempObj.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: padding).isActive = true
        case .toTheRight:
            tempObj.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -padding).isActive = true
        }
        return tempObj
    }
    func absoluteFitToThe(child: UIView, parent: UIView, padding: CGFloat) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = fitTopBottom(child: tempObj, parent: parent, padding: padding)
        tempObj = fitLeftRight(child: tempObj, parent: parent, padding: padding)
        return tempObj
    }
    func fitAtTop(child: UIView, parent: UIView, padding: CGFloat) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = fitToThe(toSide: .toTheTop, padding: padding, child: tempObj, parent: parent)
        tempObj = fitLeftRight(child: tempObj, parent: parent, padding: padding)
        return tempObj
    }
    func fitAtBottom(child: UIView, parent: UIView, padding: CGFloat) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = fitLeftRight(child: tempObj, parent: parent, padding: padding)
        tempObj = fitToThe(toSide: .toTheBottom, padding: padding, child: tempObj, parent: parent)
        return tempObj
    }
    func absoluteCenter(child: UIView, parent: UIView) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = centerVertically(child: tempObj, parent: parent, padding: 0)
        tempObj = centerHorizontally(child: tempObj, parent: parent, padding: 0)
        return tempObj
    }
    func centerVertically(child: UIView, parent: UIView, padding: CGFloat) -> UIView {
        let tempObj = child
        tempObj.isAutoResize(false)
        tempObj.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        return tempObj
    }
    func centerHorizontally(child: UIView, parent: UIView, padding: CGFloat) -> UIView {
        let tempObj = child
        tempObj.isAutoResize(false)
        tempObj.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        return tempObj
    }
    func configStackView(child: UIStackView, parent: UIScrollView) -> UIStackView {
        let tempObj = child
        tempObj.isAutoResize(false)
        tempObj.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        tempObj.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        tempObj.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 20).isActive = true
        tempObj.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        tempObj.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        return tempObj
    }
    func fitLeftRight(child: UIView, parent: UIView, padding: CGFloat) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = fitToThe(toSide: .toTheLeft, padding: padding, child: tempObj, parent: parent)
        tempObj = fitToThe(toSide: .toTheRight, padding: padding, child: tempObj, parent: parent)
        return tempObj
    }
    func fitTopBottom(child: UIView, parent: UIView, padding: CGFloat) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = fitToThe(toSide: .toTheTop, padding: padding, child: tempObj, parent: parent)
        tempObj = fitToThe(toSide: .toTheBottom, padding: padding, child: tempObj, parent: parent)
        return tempObj
    }
    // Overite function with different type
    func absoluteFitToThe(child: UIView, parent: UILayoutGuide, padding: CGFloat) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = fitToThe(toSide: .toTheTop, padding: padding, child: tempObj, parent: parent)
        tempObj = fitToThe(toSide: .toTheBottom, padding: padding, child: tempObj, parent: parent)
        tempObj = fitToThe(toSide: .toTheLeft, padding: padding, child: tempObj, parent: parent)
        tempObj = fitToThe(toSide: .toTheRight, padding: padding, child: tempObj, parent: parent)
        return tempObj
    }
    func fitToThe(toSide: ChooseSide, padding: CGFloat, child: UIView, parent: UILayoutGuide) -> UIView {
        let tempObj = child
        tempObj.isAutoResize(false)
        switch toSide {
        case .toTheTop:
            tempObj.topAnchor.constraint(equalTo: parent.topAnchor, constant: padding).isActive = true
        case .toTheBottom:
            tempObj.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -padding).isActive = true
        case .toTheLeft:
            tempObj.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: padding).isActive = true
        case .toTheRight:
            tempObj.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -padding).isActive = true
        }
        return tempObj
    }
    func absoluteCenter(child: UIView, parent: UILayoutGuide) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = centerVertically(child: tempObj, parent: parent, padding: 0)
        tempObj = centerHorizontally(child: tempObj, parent: parent, padding: 0)
        return tempObj
    }
    func centerVertically(child: UIView, parent: UILayoutGuide, padding: CGFloat) -> UIView {
        let tempObj = child
        tempObj.isAutoResize(false)
        tempObj.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        return tempObj
    }
    func centerHorizontally(child: UIView, parent: UILayoutGuide, padding: CGFloat) -> UIView {
        let tempObj = child
        tempObj.isAutoResize(false)
        tempObj.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        return tempObj
    }
    func fitAtTop(child: UIView, parent: UILayoutGuide, padding: CGFloat) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = fitToThe(toSide: .toTheTop, padding: padding, child: tempObj, parent: parent)
        tempObj = fitLeftRight(child: tempObj, parent: parent, padding: padding)
        return tempObj
    }
    func fitAtBottom(child: UIView, parent: UILayoutGuide, padding: CGFloat) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = fitLeftRight(child: tempObj, parent: parent, padding: padding)
        tempObj = fitToThe(toSide: .toTheBottom, padding: padding, child: tempObj, parent: parent)
        return tempObj
    }
    func fitTopBottom(child: UIView, parent: UILayoutGuide, padding: CGFloat) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = fitToThe(toSide: .toTheTop, padding: padding, child: tempObj, parent: parent)
        tempObj = fitToThe(toSide: .toTheBottom, padding: padding, child: tempObj, parent: parent)
        return tempObj
    }
    func fitLeftRight(child: UIView, parent: UILayoutGuide, padding: CGFloat) -> UIView {
        var tempObj = child
        tempObj.isAutoResize(false)
        tempObj = fitToThe(toSide: .toTheLeft, padding: padding, child: tempObj, parent: parent)
        tempObj = fitToThe(toSide: .toTheRight, padding: padding, child: tempObj, parent: parent)
        return tempObj
    }
}
