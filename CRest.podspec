Pod::Spec.new do |cfc|
    cfc.name         = "CRest"
    cfc.version      = "1.0.0"
    cfc.summary      = "Rest-клиент для iOS"
    cfc.description  = <<-DESC
    Библиотека содержит rest-клиент для создания iOS приложения
    DESC
    spec.license      = { :type => "MIT", :file => "LICENSE" }
    spec.author       = { "Ayham Hylam" => "Ayham Hylam" }
    spec.homepage     = "https://github.com/ayham-achami/CRest"

    cfc.ios.deployment_target = "11.0"

    cfc.source = {
        :git => "git@github.com:ayham-achami/CRest.git",
        :tag => spec.version.to_s
    }
    cfc.frameworks = "Foundation"
    cfc.requires_arc = true
    cfc.swift_versions = ['5.0', '5.1']
    cfc.pod_target_xcconfig = { "SWIFT_VERSION" => "5" }
    cfc.source_files = 'Sources/**/*.swift'
    cfc.dependency "Alamofire"
    cfc.dependency "CFoundation"
end
