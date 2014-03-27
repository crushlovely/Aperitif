Pod::Spec.new do |s|
  s.name             = "CRLInstallrChecker"
  s.version          = "0.1.0"
  s.summary          = "Check Installr for a new version of your app and prompt users to update."
  s.homepage         = "http://github.com/crushlovely"
  s.license          = 'MIT'
  s.author           = { "Tim Clem" => "tim.clem@gmail.com" }
  s.source           = { :git => "https://github.com/crushlovely/CRLInstallrChecker.git", :branch => "master" }

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.resources = 'Assets/*.xib'

  s.public_header_files = 'Classes/CRLInstallrChecker.h'
  s.dependency 'MZFormSheetController', '~> 2.3.3'
end
