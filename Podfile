# Sources
source 'https://github.com/CocoaPods/specs.git'

install! 'cocoapods', :warn_for_unused_master_specs_repo => false

# Project
project 'CRest.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

def dependencies_frameworks
  # Networking
  pod 'CFoundation', :git => 'git@github.com:ayham-achami/CFoundation.git', :branch => 'mainline'
  pod 'Alamofire', :git => 'git@github.com:Alamofire/Alamofire.git', :branch => 'feature/async-handlers'
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

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
