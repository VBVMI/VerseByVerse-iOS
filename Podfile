source 'https://github.com/CocoaPods/Specs.git'
# Uncomment this line if you're using Swift

def common_pods
    # API
    pod 'Moya', '8.0.0-beta.2'
    pod 'Alamofire'
    pod 'Decodable'
    
    # Data
    #pod 'SuperRecord'
    pod 'STRegex'
    #pod 'SwiftString' probably not going to get swift 3 compatibility
    
    # Logging
    pod 'XCGLogger'
    #pod 'XCGLoggerNSLoggerConnector', :configurations => ['Debug']
    
    # UI
    pod 'SnapKit'
    pod 'AlamofireImage'
    
    # pod 'FontAwesome.swift', git: 'git@github.com:thii/FontAwesome.swift.git'
    # pod 'SwiftIconFont', git: 'git@github.com:0x73/SwiftIconFont.git'
    
    
    pod 'Fabric'
    pod 'Crashlytics'
    
    #
    # pod 'NSLogger', :configurations => ['Debug']
    
    pod 'ReachabilitySwift'
    
    pod 'Reveal-SDK', :configurations => ['Debug']
    pod 'VimeoNetworking', git: 'https://github.com/vimeo/VimeoNetworking.git', branch: 'develop'
    #pod 'VIMVideoPlayer'
end

def ios_pods
    
    pod 'CSStickyHeaderFlowLayout'
    pod 'ACPDownload'
    
    pod 'UIImage-Color'
    pod 'FontAwesome.swift', git: 'git@github.com:thii/FontAwesome.swift.git'

end

target 'VBVMI' do
    platform :ios, '9.0'
    use_frameworks!
    inhibit_all_warnings!
    
    common_pods
    
    ios_pods
    
    
    
    target 'VBVMITests' do
        
    end
    
    target 'VBVMIUITests' do
        
    end
end

target 'VBVMI-tvOS' do
    platform :tvos, '9.0'
    use_frameworks!
    inhibit_all_warnings!
    
    common_pods
    
    pod 'ParallaxView'
#    pod 'FontAwesomeKit'
#    pod 'XCDYouTubeKit'
    #pod 'FontAwesome.swift', git: 'git@github.com:thii/FontAwesome.swift.git'
    
    target 'VBVMI-tvOSTests' do
        
    end
    
    target 'VBVMI-tvOSUITests' do
        
    end
end


post_install do | installer |
    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
