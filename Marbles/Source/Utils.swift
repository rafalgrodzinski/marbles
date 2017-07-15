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


let π = Float.pi

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
    var command: ((_ state: State) -> Void)?
    weak var nextState: State?

    func execute()
    {
        self.command?(self)
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
    return CGSize(width: left.width * right, height: left.height * right)
}


// MARK: - Extension -
extension SCNNode
{
    func duplicate() -> SCNNode
    {
        let node = self.clone()
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


    class func marblesLightGreen() -> UIColor
    {
        return UIColor(red: 0.64, green: 0.78, blue: 0.58, alpha: 1.0)
    }


    class func marblesOrange() -> UIColor
    {
        return UIColor(red: 0.78, green: 0.38, blue: 0.03, alpha: 1.0)
    }
}


extension SCNMatrix4
{
 init(simdMatrix: simd_float4x4)
    {
        self.init(m11: simdMatrix.columns.0.x, m12: simdMatrix.columns.0.y, m13: simdMatrix.columns.0.z, m14: simdMatrix.columns.0.w,
                  m21: simdMatrix.columns.1.x, m22: simdMatrix.columns.1.y, m23: simdMatrix.columns.1.z, m24: simdMatrix.columns.1.w,
                  m31: simdMatrix.columns.2.x, m32: simdMatrix.columns.2.y, m33: simdMatrix.columns.2.z, m34: simdMatrix.columns.2.w,
                  m41: simdMatrix.columns.3.x, m42: simdMatrix.columns.3.y, m43: simdMatrix.columns.3.z, m44: simdMatrix.columns.3.w)
    }
}
