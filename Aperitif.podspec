Pod::Spec.new do |s|
  s.name             = 'Aperitif'
  s.version          = '0.1.0'
  s.summary          = 'Check Installr for a new version of your app and prompt users to update.'
  s.homepage         = 'http://github.com/crushlovely/Aperitif'
  s.license          = 'MIT'
  s.authors          = { 'Crush & Lovely' => 'engineering@crushlovely.com', 'Tim Clem' => 'tim@crushlovely.com' }
  s.source           = { :git => 'https://github.com/crushlovely/Aperitif.git', :branch => 'master' }

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.resources = 'Assets/*.xib'
  s.public_header_files = 'Classes/CRLAperitif.h'

  s.dependency 'MZFormSheetController', '~> 2.3.3'
end
