//
//  Utils.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 25/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import CoreGraphics
import SceneKit
import Darwin


#if os(iOS)
let π = Float.pi
#else
let π = CGFloat.pi
#endif

#if os(iOS)
    typealias FloatType = Float
#else
    typealias FloatType = CGFloat
#endif

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

extension SCNMatrix4
{
 init(simdMatrix: simd_float4x4)
    {
        self.init(m11: FloatType(simdMatrix.columns.0.x), m12: FloatType(simdMatrix.columns.0.y), m13: FloatType(simdMatrix.columns.0.z), m14: FloatType(simdMatrix.columns.0.w),
                  m21: FloatType(simdMatrix.columns.1.x), m22: FloatType(simdMatrix.columns.1.y), m23: FloatType(simdMatrix.columns.1.z), m24: FloatType(simdMatrix.columns.1.w),
                  m31: FloatType(simdMatrix.columns.2.x), m32: FloatType(simdMatrix.columns.2.y), m33: FloatType(simdMatrix.columns.2.z), m34: FloatType(simdMatrix.columns.2.w),
                  m41: FloatType(simdMatrix.columns.3.x), m42: FloatType(simdMatrix.columns.3.y), m43: FloatType(simdMatrix.columns.3.z), m44: FloatType(simdMatrix.columns.3.w))
    }
}

private var _topMargin: CGFloat = 0.0
extension UIView
{
    class var topMargin: CGFloat {
        get {
            return _topMargin
        }
        set {
            _topMargin = newValue
        }
    }
}
