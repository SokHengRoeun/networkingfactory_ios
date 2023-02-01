//
//  ConstraintManager.swift
//  networkingfactory
//
//  Created by SokHeng on 16/12/22.
//

import Foundation
import UIKit

extension UIView {
    enum ChooseSide {
        case toTheTop
        case toTheBottom
        case toTheLeft
        case toTheRight
    }
    func fitToThe(toSide: ChooseSide, padding: CGFloat, parent: UIView) {
        self.isAutoResize(false)
        switch toSide {
        case .toTheTop:
            self.topAnchor.constraint(equalTo: parent.topAnchor, constant: padding).isActive = true
        case .toTheBottom:
            self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -padding).isActive = true
        case .toTheLeft:
            self.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: padding).isActive = true
        case .toTheRight:
            self.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -padding).isActive = true
        }
    }
    func absoluteFitToThe(parent: UIView, padding: CGFloat) {
        self.isAutoResize(false)
        self.fitTopBottom(parent: parent, padding: padding)
        self.fitLeftRight(parent: parent, padding: padding)
    }
    func fitAtTop(parent: UIView, padding: CGFloat) {
        self.isAutoResize(false)
        self.fitToThe(toSide: .toTheTop, padding: padding, parent: parent)
        self.fitLeftRight(parent: parent, padding: padding)
    }
    func fitAtBottom(parent: UIView, padding: CGFloat) {
        self.isAutoResize(false)
        self.fitLeftRight(parent: parent, padding: padding)
        self.fitToThe(toSide: .toTheBottom, padding: padding, parent: parent)
    }
    func absoluteCenter(parent: UIView) {
        self.isAutoResize(false)
        self.centerVertically(parent: parent, padding: 0)
        self.centerHorizontally(parent: parent, padding: 0)
    }
    func centerVertically(parent: UIView, padding: CGFloat) {
        self.isAutoResize(false)
        self.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
    }
    func centerHorizontally(parent: UIView, padding: CGFloat) {
        self.isAutoResize(false)
        self.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
    }
    func configStackView(parent: UIScrollView) {
        self.isAutoResize(false)
        self.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 20).isActive = true
        self.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }
    func fitLeftRight(parent: UIView, padding: CGFloat) {
        self.isAutoResize(false)
        self.fitToThe(toSide: .toTheLeft, padding: padding, parent: parent)
        self.fitToThe(toSide: .toTheRight, padding: padding, parent: parent)
    }
    func fitTopBottom(parent: UIView, padding: CGFloat) {
        self.isAutoResize(false)
        self.fitToThe(toSide: .toTheTop, padding: padding, parent: parent)
        self.fitToThe(toSide: .toTheBottom, padding: padding, parent: parent)
    }
    // Overite function with different type
    func absoluteFitToThe(parent: UILayoutGuide, padding: CGFloat) {
        self.isAutoResize(false)
        self.fitToThe(toSide: .toTheTop, padding: padding, parent: parent)
        self.fitToThe(toSide: .toTheBottom, padding: padding, parent: parent)
        self.fitToThe(toSide: .toTheLeft, padding: padding, parent: parent)
        self.fitToThe(toSide: .toTheRight, padding: padding, parent: parent)
    }
    func fitToThe(toSide: ChooseSide, padding: CGFloat, parent: UILayoutGuide) {
        self.isAutoResize(false)
        switch toSide {
        case .toTheTop:
            self.topAnchor.constraint(equalTo: parent.topAnchor, constant: padding).isActive = true
        case .toTheBottom:
            self.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -padding).isActive = true
        case .toTheLeft:
            self.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: padding).isActive = true
        case .toTheRight:
            self.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -padding).isActive = true
        }
    }
    func absoluteCenter(parent: UILayoutGuide) {
        self.isAutoResize(false)
        self.centerVertically(parent: parent, padding: 0)
        self.centerHorizontally(parent: parent, padding: 0)
    }
    func centerVertically(parent: UILayoutGuide, padding: CGFloat) {
        self.isAutoResize(false)
        self.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
    }
    func centerHorizontally(parent: UILayoutGuide, padding: CGFloat) {
        self.isAutoResize(false)
        self.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
    }
    func fitAtTop(parent: UILayoutGuide, padding: CGFloat) {
        self.isAutoResize(false)
        self.fitToThe(toSide: .toTheTop, padding: padding, parent: parent)
        self.fitLeftRight(parent: parent, padding: padding)
    }
    func fitAtBottom(parent: UILayoutGuide, padding: CGFloat) {
        self.isAutoResize(false)
        self.fitLeftRight(parent: parent, padding: padding)
        self.fitToThe(toSide: .toTheBottom, padding: padding, parent: parent)
    }
    func fitTopBottom(parent: UILayoutGuide, padding: CGFloat) {
        self.isAutoResize(false)
        self.fitToThe(toSide: .toTheTop, padding: padding, parent: parent)
        self.fitToThe(toSide: .toTheBottom, padding: padding, parent: parent)
    }
    func fitLeftRight(parent: UILayoutGuide, padding: CGFloat) {
        self.isAutoResize(false)
        self.fitToThe(toSide: .toTheLeft, padding: padding, parent: parent)
        self.fitToThe(toSide: .toTheRight, padding: padding, parent: parent)
    }
}
