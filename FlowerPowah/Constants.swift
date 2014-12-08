//
//  Constants.swift
//  FlowerPowah
//
//  Created by Kj Drougge on 2014-12-08.
//  Copyright (c) 2014 kj. All rights reserved.
//

import Foundation
import UIKit

//MARK: constants
let StemTextureImage = "RopeTexture"
let FlowerTextureImage = "Flower"
let Flower2TextureImage = "Flower2"
let LeafTextureImage = "Leaf"
let GrassImage = "Grass"

struct Layer{
    static let Background: CGFloat = 0
    static let Stem: CGFloat = 1
    static let Leaf: CGFloat = 1
    static let Flower: CGFloat = 2
    static let Foreground: CGFloat = 3
}

struct Category{
    static let Stem: UInt32 = 1
    static let Flower: UInt32 = 2
    static let StemHolder: UInt32 = 4
    static let Leaf: UInt32 = 8
}


let FlowerIsDynamicsOnStart = true