# Sources
source 'https://github.com/CocoaPods/specs.git'

install! 'cocoapods', :warn_for_unused_master_specs_repo => false

# Project
project 'CRest.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
##################################################################
# Tools
##################################################################
def tools
  pod 'SwiftLint'
end
##################################################################
# Architecture
##################################################################
def architecture
  pod 'CFoundation', :git => 'https://github.com/ayham-achami/CFoundation.git', :branch => 'mainline'
end
##################################################################
# Networking
##################################################################
def networking
  pod 'Alamofire'
end
##################################################################
# CRest Framework
##################################################################
target 'CRest' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  tools
  architecture
  networking
  
  target 'CRestTests' do
    inherit! :complete
  end
end
