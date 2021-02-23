Pod::Spec.new do |s|

	s.name             = 'UseDesk_SDK_Swift'
	s.version          = '1.1.0'
	s.summary          = 'A short description of UseDesk.'

	s.description      = <<-DESC
						TODO: Add long description of the pod here.
	                   DESC

	s.homepage         = 'https://github.com/usedesk/UseDeskSwift'
	s.license          = { :type => 'MIT', :file => 'LICENSE' }
	s.author           = { 'serega@budyakov.com' => 'kon.sergius@gmail.com' }
	s.source           = { :git => 'https://github.com/usedesk/UseDeskSwift.git', :tag => s.version.to_s }

	s.ios.deployment_target = '10.0'
	s.swift_version = '4.0'
	s.static_framework = true

	s.ios.source_files = 'UseDesk/Classes/*.{m,h,swift}'

#	s.resource_bundles = {
#		'UseDesk' => ['UseDesk/Assets/*.{png,xcassets,imageset,jpeg,jpg}', 'UseDesk/Classes/*.{storyboard,xib,bundle}']
#	}
  
  s.resource = ['UseDesk/**/*.{png,xcassets,imageset,jpeg,jpg,storyboard,xib,bundle,strings}']

	s.frameworks = 'UIKit', 'MapKit' ,'AVFoundation'

	s.dependency 'MBProgressHUD', '~> 1.0'
	s.dependency 'NYTPhotoViewer', '1.2.0'
	s.dependency 'ProgressHUD'
	s.dependency 'Socket.IO-Client-Swift', '~> 14.0'
	s.dependency 'Alamofire', '~> 5'
	s.dependency 'QBImagePickerController', '~> 3.4'
	s.dependency 'UIAlertController+Blocks'
  s.dependency 'Swime'

end
