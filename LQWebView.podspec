#
#  Be sure to run `pod spec lint LQWebView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "LQWebView"
  s.version      = "1.3.2"
  s.summary      = "对WKWebView 的封装，继承自UIView"
  s.description  = <<-DESC
  对WKWebView 的封装，继承自UIView，封装了常用方法，方便使用！
                   DESC

  s.homepage     = "https://github.com/LQi2009/LQWebView"
  s.license      = "MIT"
  s.author             = { "LiuQiqiang" => "lqq200912408@163.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/LQi2009/LQWebView.git", :tag => "#{s.version}" }


  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

  s.source_files  = 'LQWebView/obj/*.{h,m}'

  # s.default_subspec = 'OBJ'
  
  # s.subspec 'OBJ' do |obj|
  #   obj.source_files  = 'LQWebView/obj/*.{h,m}'
  # end


end
