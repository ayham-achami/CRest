Pod::Spec.new do |spec|
    spec.name         = "CRest"
    spec.version      = "1.0.0"
    spec.summary      = "Rest-клиент для iOS"
    spec.description  = <<-DESC
    Библиотека содержит rest-клиент для создания iOS приложения
    DESC
    spec.license      = { :type => "MIT", :file => "LICENSE" }
    spec.author       = { "Ayham Hylam" => "Ayham Hylam" }
    spec.homepage     = "https://github.com/ayham-achami/CRest"

    spec.ios.deployment_target = "13.0"

    spec.source = {
        :git => "git@github.com:ayham-achami/CRest.git",
        :tag => spec.version.to_s
    }
    spec.frameworks = "Foundation"
    spec.requires_arc = true
    spec.swift_versions = ['5.0', '5.1']
    spec.pod_target_xcconfig = { "SWIFT_VERSION" => "5" }
    spec.source_files = 'Sources/**/*.swift'
    spec.dependency "Alamofire"
    spec.dependency "CFoundation"
end
