//
//  Routines.swift
//  StepByStep
//
//  Created by Yune gim on 2023/05/07.
//

import Foundation

struct Routines : Codable{
    var Routines : [Routine]
}

struct Routine: Codable {
    
    let itemName : String
    let itemDisc : String
    let start : String
    let end : String

}
