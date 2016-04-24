//
//  Game.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 24/04/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//

import UIKit


class Game {
    internal(set) var view: UIView!
    internal var field: Field


    // MARK: - Initialization -
    init(field: Field)
    {
        self.field = field
        self.setupView()
        assert(self.view != nil, "self.view must not be nil")

        self.setupCustom()
    }


    // MARK: <<Abstract>>
    func setupView()
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: <<Abstract>>
    func setupCustom()
    {
        assert(false, "<<Abstract method>>")
    }


    // MARK: - Control -

    // MARK: <<Abstract>>
    func startGame()
    {
        assert(false, "<<Abstract method>>")
    }
}
