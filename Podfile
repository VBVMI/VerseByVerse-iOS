# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!
inhibit_all_warnings!

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
pod 'CSStickyHeaderFlowLayout'
pod 'FontAwesome.swift', git: 'git@github.com:thii/FontAwesome.swift.git'
pod 'ACPDownload'
pod 'UIImage-Color'

pod 'Fabric'
pod 'Crashlytics'

pod 'Reveal-iOS-SDK', :configurations => ['Debug']
# pod 'NSLogger', :configurations => ['Debug']

pod 'ReachabilitySwift'

target 'VBVMI' do
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
    end
end

target 'VBVMITests' do

end

target 'VBVMIUITests' do

end
