//
//  PathFinderProtocol.swift
//  Kulki
//
//  Created by Rafal Grodzinski on 03/05/16.
//  Copyright © 2016 UnalignedByte. All rights reserved.
//


protocol PathFinderProtocol
{
    func pathFromFieldPosition(_ from: Point, toFieldPosition to: Point, field: Field) -> [Point]?
}
