#
#  Be sure to run `pod spec lint AudioListModule.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name           = 'AudioListModule'
  spec.version        = '0.0.1'
  spec.summary        = 'A short description of AudioListModule.'
  spec.description    = <<-DESC
  Audio List Module
  DESC

  spec.homepage       = 'https://ibuldapp.com'
  spec.license        = 'COMMERCIAL'
  spec.author         = { 'Anton Boyarkin' => 'anton.boyarkin@icloud.com' }
  spec.platform       = :ios, '10.0'
  spec.source         = { :git => 'git@gitlab.vladimir.ibuildapp.com:ios/audiolistwidget.git', :tag => '#{spec.version}' }
  spec.source_files   = 'Sources/*.swift', 'Sources/**/*.swift'
  spec.resources      = 'Resources/**/*.*'
  spec.frameworks     = 'UIKit', 'Foundation'
  spec.dependency       'IBACore'
  spec.dependency       'IBACoreUI'

  spec.static_framework = true

  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/*.swift'
    test_spec.dependency 'Quick'
    test_spec.dependency 'Nimble'
  end

end
