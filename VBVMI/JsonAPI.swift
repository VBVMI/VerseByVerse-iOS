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
    case core
    case lesson(identifier: String)
    case articlesP
    case articles
    case channels
    case categories
    case curriculum
    case events
    case qa
    case qAp
}

extension JsonAPI : TargetType {
    public var headers: [String : String]? {
        return nil
    }

    public var base: String {
        return "https://www.versebyverseministry.org/corev2/"
    }
    
    public var baseURL: URL {
        return URL(string: base)!
    }
    
    public var path: String {
        switch self {
        case .core:
            return "json"
        case .lesson(let identifier):
            return "json-lessons/\(identifier)"
        case .articlesP:
            return "json-articlesp"
        case .articles:
            return "json-articles"
        case .channels:
            return "json-channels"
        case .events:
            return "json-events"
        case .qa:
            return "json-qa"
        case .qAp:
            return "json-qap"
        case .categories:
            return "categories"
        case .curriculum:
            return "json-curriculum"
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        default:
            return nil
        }
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .core:
            return stubbedResponse("core")
        case .lesson:
            return stubbedResponse("lesson")
        case .articlesP:
            return stubbedResponse("articlesP")
        case .articles:
            return stubbedResponse("articles")
        case .channels:
            return stubbedResponse("channels")
        case .events:
            return stubbedResponse("events")
        case .qa:
            return stubbedResponse("qa")
        case .qAp:
            return stubbedResponse("qap")
        case .curriculum:
            return stubbedResponse("curriculum")
        case .categories:
            return stubbedResponse("categories")
        }
    }
    
    public var task: Task {
        return .requestPlain
    }
    
    public var parameterEncoding: Moya.ParameterEncoding {
        if method == .get {
            return URLEncoding.default
        }
        switch self {
        default:
            return JSONEncoding.default
        }
    }
}

public func endpointResolver() -> ((_ endpoint: Endpoint<JsonAPI>) -> (URLRequest)) {
    return { (endpoint: Endpoint<JsonAPI>) -> (URLRequest) in
        let request: URLRequest = try! endpoint.urlRequest()
        return request
    }
}

public struct Provider {
    fileprivate static var endpointsClosure = { (target: JsonAPI) -> Endpoint<JsonAPI> in
        let sampleResponse : Endpoint.SampleResponseClosure  = { return EndpointSampleResponse.networkResponse(200, target.sampleData) }
        
        var endpoint : Endpoint<JsonAPI> = Endpoint(url: url(target), sampleResponseClosure: sampleResponse, method: target.method, task:  target.task, httpHeaderFields: nil)
        
        switch target {
        default:
            return endpoint
        }
    }
    public typealias ProviderRequest = ()->()
    
    public static func APIKeysBasedStubBehaviour(_ target: JsonAPI) -> Moya.StubBehavior {
        switch target {
        default:
            #if API_DEBUG
            return .delayed(seconds: 0.2) //.never //
            #else
            return .never
            #endif
        }
    }
    
    fileprivate static var ongoingRequestCount = 0 {
        didSet {
            #if os(iOS)
               UIApplication.shared.isNetworkActivityIndicatorVisible = ongoingRequestCount > 0
            #endif
        }
    }
    
    public static func DefaultProvider() -> MoyaProvider<JsonAPI> {
        let networkActivityPlugin = NetworkActivityPlugin { (change, target) -> () in
            DispatchQueue.main.async {
                switch change {
                case .began:
                    ongoingRequestCount += 1
                case .ended:
                    ongoingRequestCount -= 1
                }
            }
        }
        let provider = MoyaProvider<JsonAPI>(endpointClosure: endpointsClosure, stubClosure: APIKeysBasedStubBehaviour, plugins: [networkActivityPlugin])
        
        return provider
    }
    
    fileprivate struct SharedProvider {
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

private func stubbedResponse(_ filename: String) -> Data! {
    @objc class TestClass : NSObject { }
    let bundle = Bundle(for: TestClass.self)
    if let path = bundle.path(forResource: filename, ofType: "json") {
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    return Data()
}

public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}
