
Pod::Spec.new do |s|
  s.name             = 'PredicateExpression'
  s.version          = '1.0.0'
  s.summary          = 'The DLS that simplify creating NSPredicate objects via expressions.'

  s.homepage         = 'https://github.com/marcinjucha/PredicateExpression'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Marcin Jucha' => 'mjucha92@gmail.com' }
  s.source           = { :git => 'https://github.com/marcinjucha/PredicateExpression.git', :tag => "1.0.0" }

  s.ios.deployment_target = '8.0'
  s.swift_versions = '5.0'

  s.source_files = 'Sources/**/*'
  s.frameworks = 'Foundation'
  
end
