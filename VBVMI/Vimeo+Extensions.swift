//
//  Vimeo+Extensions.swift
//  VBVMI
//
//  Created by Thomas Carey on 25/04/17.
//  Copyright © 2017 Tom Carey. All rights reserved.
//

import Foundation
import VimeoNetworking

/// Extend app configuration to provide a default configuration
private extension AppConfiguration
{
    /// The default configuration to use for this application, populate your client key, secret, and scopes.
    /// Also, don't forget to set up your application to receive the code grant authentication redirect, see the README for details.
    static let defaultConfiguration = AppConfiguration(clientIdentifier: VimeoClientIdentifier, clientSecret: VimeoClientSecret, scopes: [Scope.Public, Scope.Private], keychainService: "org.vbv")
}

/// Extend vimeo client to provide a default client
extension VimeoClient
{
    /// The default client this application should use for networking, must be authenticated by an `AuthenticationController` before sending requests
    static let defaultClient = VimeoClient(appConfiguration: AppConfiguration.defaultConfiguration)
}
