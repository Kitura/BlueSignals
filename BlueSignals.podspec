Pod::Spec.new do |s|
s.name        = "BlueSignals"
s.version     = "2.0.0"
s.summary     = "Swift cross-platform OS signals handler."
s.homepage    = "https://github.com/Kitura/BlueSignals"
s.license     = { :type => "Apache License, Version 2.0" }
s.author     = "IBM"
s.module_name  = 'Signals'

s.requires_arc = true
s.osx.deployment_target = "10.11"
s.ios.deployment_target = "10.0"
s.tvos.deployment_target = "10.0"
s.source   = { :git => "https://github.com/Kitura/BlueSignals.git", :tag => s.version }
s.source_files = "Sources/Signals/*.swift"
s.pod_target_xcconfig =  {
'SWIFT_VERSION' => '5.0',
}
end
