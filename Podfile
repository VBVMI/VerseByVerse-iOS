source 'https://github.com/CocoaPods/Specs.git'
# Uncomment this line if you're using Swift

def common_pods
    # API
    pod 'Moya'
    pod 'Alamofire'
    
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

    pod 'VimeoNetworking'
    #pod 'VIMVideoPlayer'
end

def ios_pods

    pod 'CSStickyHeaderFlowLayout'
    pod 'ACPDownload'

    pod 'Firebase/Core'
    pod 'UIImage-Color'

end

target 'VBVMI' do
    platform :ios, '11.0'
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
    platform :tvos, '11.0'
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


#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#        target.build_configurations.each do |config|
##            if ['Nothing'].include? target.name
##                config.build_settings['SWIFT_VERSION'] = '3.2'
##                else
##                config.build_settings['SWIFT_VERSION'] = '5.0'
##            end
#            
#            
#        end
#    end
#end
