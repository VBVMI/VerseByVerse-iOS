//
//  JsonAPI.swift
//  VBVMI
//
//  Created by Thomas Carey on 31/01/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import Moya

public enum JsonAPI {
    case Core
    case Lesson(identifier: String)
    case ArticlesP
    case Articles
    case Channels
    case Events
    case QA
    case QAp
}

extension JsonAPI : TargetType {
    public var base: String {
        return "https://www.versebyverseministry.org/core/"
    }
    
    public var baseURL: NSURL {
        return NSURL(string: base)!
    }
    
    public var path: String {
        switch self {
        case Core:
            return "json"
        case .Lesson(let identifier):
            return "json-lessons/\(identifier)"
        case .ArticlesP:
            return "json-articlesp"
        case .Articles:
            return "json-articles"
        case .Channels:
            return "json-channels"
        case .Events:
            return "json-events"
        case .QA:
            return "json-qa"
        case .QAp:
            return "json-qap"
        }
    }
    
    public var parameters: [String: AnyObject]? {
        switch self {
        default:
            return nil
        }
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return .GET
        }
    }
    
    public var sampleData: NSData {
        switch self {
        case Core:
            return stubbedResponse("core")
        case Lesson:
            return stubbedResponse("lesson")
        case .ArticlesP:
            return stubbedResponse("articlesP")
        case .Articles:
            return stubbedResponse("articles")
        case .Channels:
            return stubbedResponse("channels")
        case .Events:
            return stubbedResponse("events")
        case .QA:
            return stubbedResponse("qa")
        case .QAp:
            return stubbedResponse("qap")
        }
    }
    
    public var task: Task {
        return .Request
    }
    
    public var parameterEncoding: Moya.ParameterEncoding {
        if method == .GET {
            return .URL
        }
        switch self {
        default:
            return .JSON
        }
    }
}

public func endpointResolver() -> ((endpoint: Endpoint<JsonAPI>) -> (NSURLRequest)) {
    return { (endpoint: Endpoint<JsonAPI>) -> (NSURLRequest) in
        let request: NSMutableURLRequest = endpoint.urlRequest.mutableCopy() as! NSMutableURLRequest
        //        request.HTTPShouldHandleCookies = false
        return request
    }
}

public struct Provider {
    private static var endpointsClosure = { (target: JsonAPI) -> Endpoint<JsonAPI> in
        let sampleResponse : Endpoint.SampleResponseClosure  = { return EndpointSampleResponse.NetworkResponse(200, target.sampleData) }
        
        var endpoint : Endpoint<JsonAPI> = Endpoint(URL: url(target), sampleResponseClosure: sampleResponse, method: target.method, parameters:  target.parameters, parameterEncoding: target.parameterEncoding, httpHeaderFields: nil)
        
        switch target {
        default:
            return endpoint
        }
    }
    public typealias ProviderRequest = ()->()
    
    public static func APIKeysBasedStubBehaviour(target: JsonAPI) -> Moya.StubBehavior {
        switch target {
        default:
            return .Never
        }
    }
    
    private static var ongoingRequestCount = 0 {
        didSet {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = ongoingRequestCount > 0
        }
    }
    
    public static func DefaultProvider() -> MoyaProvider<JsonAPI> {
        let networkActivityPlugin = NetworkActivityPlugin { (change) -> () in
            switch change {
            case .Began:
                ongoingRequestCount += 1
            case .Ended:
                ongoingRequestCount -= 1
            }
        }
        let provider = MoyaProvider<JsonAPI>(endpointClosure: endpointsClosure, stubClosure: APIKeysBasedStubBehaviour, plugins: [networkActivityPlugin])
        
        return provider
    }
    
    private struct SharedProvider {
        static var instance = Provider.DefaultProvider()
    }

    public static var sharedProvider: MoyaProvider<JsonAPI> {
        get {
        return SharedProvider.instance
        }
        
        set (newSharedProvider) {
            SharedProvider.instance = newSharedProvider
        }
    }
}

private func stubbedResponse(filename: String) -> NSData! {
    @objc class TestClass : NSObject { }
    let bundle = NSBundle(forClass: TestClass.self)
    if let path = bundle.pathForResource(filename, ofType: "json") {
        return NSData(contentsOfFile: path)
    }
    return NSData()
}

public func url(route: TargetType) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path)!.absoluteString!
}
