//
//  Utils.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 25/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit
import SceneKit
import Darwin


let π = Float(M_PI)

// MARK - Point -
struct Point: Hashable, Equatable {
    var x: Int
    var y: Int

    init(_ x: Int, _ y: Int)
    {
        self.x = x
        self.y = y
    }

    var hashValue: Int {
        return "\(x)\(y)".hash
    }
}


func ==(left: Point, right: Point) -> Bool
{
    return left.x == right.x && left.y == right.y
}


func -(left: Point, right: Point) -> Point
{
    return Point(left.x - right.x, left.y - right.y)
}


func +(left: Point, right: Point) -> Point
{
    return Point(left.x + right.x, left.y + right.y)
}


// MARK: - Size -
struct Size {
    var width: Int
    var height: Int

    init(_ width: Int, _ height: Int)
    {
        self.width = width
        self.height = height
    }
}


// MARK: - State -
class State: Equatable {
    var command: ((state: State) -> Void)?
    weak var nextState: State?

    func execute()
    {
        self.command?(state: self)
    }

    func goToNextState()
    {
        self.nextState?.execute()
    }
}


func ==(left: State, right: State) -> Bool
{
    return left === right
}


// MARK: - Operators -
func *(left: CGSize, right: CGFloat) -> CGSize
{
    return CGSizeMake(left.width * right, left.height * right)
}


// MARK: - Extension -
extension SCNNode
{
    func duplicate() -> SCNNode
    {
        let node = self.flattenedClone()
        node.geometry = self.geometry?.copy() as? SCNGeometry
        node.geometry?.firstMaterial = self.geometry?.firstMaterial?.copy() as? SCNMaterial

        return node
    }
}


extension UIColor
{
    class func marblesGreen() -> UIColor
    {
        return UIColor(red: 0.55, green: 0.89, blue: 0.21, alpha: 1.0)
    }
}