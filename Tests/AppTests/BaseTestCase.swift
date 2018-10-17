//
//  BaseTestCase.swift
//  AppTests
//
//  Created by Masahiko Sato on 2018/10/17.
//

@testable import App
import Vapor
import XCTest

class BaseTestCase: XCTestCase {
    var app: Application!

    override func setUp() {
        app = try! Application.testable()
        super.setUp()
    }
}
