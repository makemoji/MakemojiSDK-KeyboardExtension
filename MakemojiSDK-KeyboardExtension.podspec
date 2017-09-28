#
# Be sure to run `pod lib lint MakemojiSDK-KeyboardExtension.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MakemojiSDK-KeyboardExtension"
  s.version          = "1.1.8"
  s.summary          = "A free emoji keyboard for mobile apps"

  s.description      = <<-DESC
                       By installing our keyboard SDK every user of your app will instantly have access to new and trending emojis.  Our goal is to increase user engagement as well as provide actionable real time data on sentiment (how users feel) and affinity (what users like). With this extensive data collection your per-user & company valuation will increase along with your user-base.
                       DESC

  s.homepage         = "https://github.com/makemoji/MakemojiSDK-KeyboardExtension"
  s.author           = { "Makemoji SDK" => "sdk@makemoji.com" }
  s.license      = { :type => 'Commercial' }
  s.source       = { :git => 'https://github.com/makemoji/MakemojiSDK-KeyboardExtension.git', :tag => '1.1.8' }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.frameworks = 'SystemConfiguration', 'UIKit', 'AdSupport'
  s.dependency 'AFNetworking', '>= 2.6.3'
  s.dependency 'SDWebImage'
  s.dependency 'SDWebImage/GIF'
  s.resource_bundles = {
  	'MakemojiSDK-KeyboardExtension' => ['Pod/Assets/*']
  }  
end