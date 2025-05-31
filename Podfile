project 'UseDesk_SDK_Swift.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'UseDesk_SDK_Swift' do

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
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
  end
end
end
