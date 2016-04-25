//
//  Utils.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 25/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


// MARK - Point -
struct Point: Hashable, Equatable {
    var x: Int
    var y: Int

    init(_ x: Int, _ y: Int)
    {
        self.x = x
        self.y = y
    }

    var hashValue: Int
    {
        return "\(x)\(y)".hash
    }
}


func ==(left: Point, right: Point) -> Bool
{
    return left.x == right.x && left.y == right.y
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
class State {
    var command: ((state: State, finished: (() -> Void)?) -> Void)!
    weak var nextState: State?

    func execute()
    {
        self.command(state: self, finished: self.nextState?.execute)
    }
}


// MARK: - Operators -
func *(left: CGSize, right: CGFloat) -> CGSize
{
    return CGSizeMake(left.width * right, left.height * right)
}