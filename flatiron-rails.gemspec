Gem::Specification.new do |s|
  s.name        = 'flatiron-rails'
  s.version     = '0.0.12'
  s.executables << 'flatiron-rails'
  s.date        = '2014-03-26'
  s.summary     = "flatiron-rails gem"
  s.description = "Sets up a rails application using the default Flatiron School stack."
  s.authors     = ["Arel English", "Logan Hasson", "Katie Hoffman"]
  s.email       = "logan@flatironschool.com"
  s.files       = Dir["{bin,lib,templates}/*"]
  s.homepage    =
    'http://rubygems.org/gems/flatiron-rails'
  s.license     = 'MIT'
  s.add_runtime_dependency('rails', '>= 4.1.0.rc1')
end