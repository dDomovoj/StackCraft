Pod::Spec.new do |s|
    s.name = 'StackCraft'
    s.version = '0.3.2'
    s.summary = 'Stack views on frames library'
    s.swift_version = '5.4'
  
    s.homepage = 'https://github.com/dDomovoj/StackCraft'
    s.license = { :type => "MIT" }
    s.author = { 
      'Dzmitry Duleba' => 'dmitryduleba@gmail.com'
    }
    s.source = { :git => 'https://github.com/dDomovoj/StackCraft.git', :tag => s.version.to_s }
    s.framework = ["UIKit", "Foundation"]
  
    s.ios.deployment_target = '11.0'
    s.source_files = 'Sources/StackCraft/*.swift'
  
  end
  
