Pod::Spec.new do |s|

	s.name             = 'UseDesk_SDK_Swift'
	s.version          = '3.4.10'
	s.summary          = 'A short description of UseDesk.'

	s.homepage         = 'https://github.com/usedesk/UseDeskSwift'
	s.license          = { :type => 'MIT', :file => 'LICENSE' }
	s.author           = { 'serega@budyakov.com' => 'kon.sergius@gmail.com' }
	s.source           = { :git => 'https://github.com/usedesk/UseDeskSwift.git', :tag => s.version.to_s }

	s.ios.deployment_target = '11.0'
	s.swift_version = '5.0'
	s.static_framework = true

  s.ios.source_files = ['UseDesk/Classes/*.{m,h,swift,}', 'Core/*.{m,h,swift}']

  s.resource_bundles = {
    'UseDesk' => ['UseDesk/Assets/*.{png,xcassets,imageset,jpeg,jpg}', 'UseDesk/Classes/*.{xib}']
  }

	s.frameworks = 'UIKit', 'MapKit' ,'AVFoundation'
  
	s.dependency 'Socket.IO-Client-Swift', '~> 16'
	s.dependency 'Alamofire', '~> 5'
  s.dependency 'MarkdownKit'
  s.dependency 'Texture'
  s.dependency 'ReachabilitySwift'
  s.dependency 'SwiftSoup'
  
end
