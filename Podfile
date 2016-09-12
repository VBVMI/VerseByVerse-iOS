# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!
inhibit_all_warnings!

# API
pod 'Moya', git: 'git@github.com:Moya/Moya.git'
pod 'Alamofire'
pod 'Decodable'

# Data
#pod 'SuperRecord'
pod 'STRegex'
pod 'SwiftString'

# Logging
pod 'XCGLogger'
pod 'XCGLoggerNSLoggerConnector', :configurations => ['Debug']

# UI
pod 'SnapKit'
pod 'AlamofireImage', '~> 2.0'
pod 'CSStickyHeaderFlowLayout'
pod 'FontAwesome.swift', git: 'git@github.com:thii/FontAwesome.swift.git', branch: 'swift-2.3'
pod 'ACPDownload'
pod 'UIImage-Color'

pod 'Fabric'
pod 'Crashlytics'

pod 'Reveal-iOS-SDK', :configurations => ['Debug']
pod 'NSLogger', :configurations => ['Debug']

pod 'ReachabilitySwift'

target 'VBVMI' do
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '2.3'
            end
        end
    end
end

target 'VBVMITests' do

end

target 'VBVMIUITests' do

end
