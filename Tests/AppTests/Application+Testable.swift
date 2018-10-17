//
//  Application+Testable.swift
//  AppTests
//
//  Created by Masahiko Sato on 2018/10/16.
//

@testable import App
import Vapor

extension Application {
    static func testable() throws -> Application {
        var config = Config.default()
        var env = Environment.testing
        var services = Services.default()
        try configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        try boot(app)
        return app
    }
}
