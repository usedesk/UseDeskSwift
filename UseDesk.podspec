Pod::Spec.new do |s|

	s.name             = 'UseDesk'
	s.version          = '2.2.1'
	s.summary          = 'A short description of UseDesk.'

	s.description      = <<-DESC
						TODO: Add long description of the pod here.
	                   DESC

	s.homepage         = 'https://github.com/BugorBN/UseDeskSwift'
	s.license          = { :type => 'MIT', :file => 'LICENSE' }
	s.author           = { 'serega@budyakov.com' => 'kon.sergius@gmail.com' }
	s.source           = { :git => 'https://github.com/BugorBN/UseDeskSwift', :tag => s.version.to_s }

	s.ios.deployment_target = '11.0'
	s.swift_version = '5.0'
	s.static_framework = true

  s.ios.source_files = ['UseDesk/Classes/*.{m,h,swift,}', 'Core/*.{m,h,swift}']

  s.resource_bundles = {
    'UseDesk' => ['UseDesk/Assets/*.{png,xcassets,imageset,jpeg,jpg}', 'UseDesk/Classes/*.{xib}']
  }

	s.frameworks = 'UIKit', 'MapKit' ,'AVFoundation'
  
	s.dependency 'Socket.IO-Client-Swift', '~> 16.0'
	s.dependency 'Alamofire', '~> 5'
  s.dependency 'Swime'
  s.dependency 'Down'
  s.dependency 'Texture'
  
end
