//
//  VimeoManager.swift
//  VBVMI
//
//  Created by Thomas Carey on 25/04/17.
//  Copyright © 2017 Tom Carey. All rights reserved.
//

import Foundation
import VimeoNetworking

enum VimeoFileQuality {
    case hls
    case hd
    case sd
    case mobile
    
    var vimeoValue: String {
        switch self {
        case .hls: return VIMVideoFileQualityHLS
        case .hd: return VIMVideoFileQualityHD
        case .mobile: return VIMVideoFileQualityMobile
        case .sd: return VIMVideoFileQualitySD
        }
    }
}

enum VimeoManagerError : Error {
    case missingQuality
}

class VimeoManager {
    
    static let shared = VimeoManager()
    
    private init() {
        
    }
    
    func getVimeoURL(vimeoVideoID: String, quality: VimeoFileQuality = .hls, callback: @escaping (Result<URL>)->()) {
        login { (result) in
            switch result {
            case .failure(let error):
                callback(Result.failure(error: error))
            case .success(_):
                let request = Request<VIMVideo>(path: "/videos/\(vimeoVideoID)")
                let _ = VimeoClient.defaultClient.request(request) { result in
                switch result {
                    case .failure(let error):
                        callback(Result.failure(error: error))
                    case .success(let result):
                        if let fileLink : String = (result.model.files?.first(where: { ($0 as? VIMVideoFile)?.quality == quality.vimeoValue }) as? VIMVideoFile)?.link, let url = URL(string: fileLink) {
                            callback(Result.success(result: url))
                        } else {
                            callback(Result.failure(error: VimeoManagerError.missingQuality as NSError))
                        }
                    }
                }
            }
        }
    }
    
    private func login(completion: @escaping (Result<VIMAccount>)->()) {
        if let account = VimeoClient.defaultClient.currentAccount, account.isAuthenticatedWithUser() {
            completion(Result.success(result: account))
        } else {
            let vimeoAuth = AuthenticationController(client: VimeoClient.defaultClient, appConfiguration: AppConfiguration.defaultConfiguration, configureSessionManagerBlock: nil)
            let token = kVimeoAccessToken
            vimeoAuth.accessToken(token: token) { (result) in
                logger.info("Vimeo Auth Result: \(result)")
                completion(result)
            }
        }
    }
    
}
