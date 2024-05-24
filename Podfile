project 'UseDesk_SDK_Swift.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'UseDesk_SDK_Swift' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for UseDesk_SDK_Swift
  pod 'Socket.IO-Client-Swift', '~> 16'
  pod 'Alamofire', '~> 5'
  pod 'MarkdownKit'
  pod 'Texture'
  pod 'ReachabilitySwift'
  pod 'SwiftSoup'

  post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'Socket.IO-Client-Swift' then
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
end
end
