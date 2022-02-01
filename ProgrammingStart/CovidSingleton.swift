//
//  CovidSingleton.swift
//  ProgrammingStart
//
//  Created by g002270 on 2022/02/01.
//


import Foundation

class CovidSingleton {
    
    private init() {}
    static let shared = CovidSingleton()
    var prefecture:[CovidInfo.Prefecture] = []
}
