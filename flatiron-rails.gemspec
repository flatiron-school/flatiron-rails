Gem::Specification.new do |s|
  s.name        = 'flatiron-rails'
  s.version     = '2.0.2'
  s.executables << 'flatiron-rails'
  s.date        = '2014-07-28'
  s.summary     = "flatiron-rails gem"
  s.description = "Sets up a rails application using the default Flatiron School stack."
  s.authors     = ["Logan Hasson"]
  s.email       = "logan@flatironschool.com"
  s.files       = Dir["{bin,lib,templates}/*"]
  s.homepage    =
    'http://rubygems.org/gems/flatiron-rails'
  s.license     = 'MIT'
  s.add_runtime_dependency('rails', '~> 4.1', '>= 4.1.4')
end
