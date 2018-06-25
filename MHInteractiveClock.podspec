Pod::Spec.new do |s|
  s.platform          = :ios
  s.ios.deployment_target   = '9.0'
  s.name         	= "MHInteractiveClock"
  s.version      	= "0.0.1"
  s.summary      	= "A customizable clock of which the handle can be interacted with."
  s.requires_arc 	= true
  s.swift_version 	= '4.0'

  s.license      	= { :type => "MIT", :file => "LICENSE" }

  s.author       	= { "Maiko Hermans" => "mwmhermans@outlook.com" }

  s.homepage     	= "https://github.com/MaikoHermans/MHInteractiveClock"

  s.source       	= { :git => "https://github.com/MaikoHermans/MHInteractiveClock.git", :tag => "#{s.version}" }

  s.frameworks    	= "UIKit"
  s.source_files 	= "MHInteractiveClock/**/*.{swift}"

end