#
#  Be sure to run `pod spec lint NBPullToRefresh.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "NBPullToRefresh"
  s.version      = "0.1.0"
  s.summary      = "A PullToRefresh Category used on iOS."

  s.description  = <<-DESC
                    a categroy of UIScrollView, implement pull to refresh and infinite refresh.
                   DESC

  s.homepage     = "https://github.com/nova8ossa/NBPullToRefresh"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = "MIT"
  s.author       = { "梵天" => "nova8ossa@gmail.com" }

  s.platform     = :ios, "7.0"
  s.requires_arc = true

  s.source       = { :git => "https://github.com/nova8ossa/NBPullToRefresh.git", :tag => "0.1.0" }
  s.source_files = "NBPullToRefresh/*"
  s.frameworks   = "UIKit", "Foundation"

end
