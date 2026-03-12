Pod::Spec.new do |s|
  s.name             = 'MobWithAD'
  s.version          = '1.3.0'
  s.summary          = 'Mobwith AD iOS SDK'
  s.description      = <<-DESC
Mobwith AD의 iOS SDK 입니다.
DESC

  s.homepage         = 'https://github.com/mobon/MobWithAD_iOS'
  s.license          = { :type => 'MIT', :text => 'Copyright 2022 by MobWith' }
  s.author           = { 'mobon' => 'dh.lee@mobwith.co.kr' }

  s.source = {
    :git => 'https://github.com/mobon/MobWithAD_iOS.git',
    :tag => s.version.to_s
  }

  s.platform = :ios, "15.6"

  s.vendored_frameworks = 'MobWithADSDKFramework.xcframework'
  
end