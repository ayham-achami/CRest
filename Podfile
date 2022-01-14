# Sources
source 'https://github.com/CocoaPods/specs.git'

install! 'cocoapods', :warn_for_unused_master_specs_repo => false

# Project
project 'CRest.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

def dependencies_frameworks
  # Networking
  pod 'CFoundation', :git => 'https://github.com/ayham-achami/CFoundation.git', :branch => 'mainline'
  pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git'
end

target 'CRest' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'SwiftLint'
  dependencies_frameworks
  
  target 'CRestTests' do
    inherit! :search_paths
  end
end
