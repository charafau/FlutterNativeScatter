//
//  SwiftBridge.swift
//  AddToAppIos
//
//  Created by Rafal Wachol on 2025/12/12.
//

import Foundation

@_cdecl("add_numbers")
public func addNumbers(a: Int32, b: Int32) -> Int32 {
    
    print("adding numbers ", a + b)
    
    return a + b
}
