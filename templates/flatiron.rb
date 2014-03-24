# Prevent automatic run of bundle install
def run_bundle ; end

# Remove sqlite3 from default gem group
File.open("Gemfile", "r+") do |f|
  out = ""
  f.each do |line|
    if line =~ /# Use sqlite3 as the database for Active Record/
      out << ""
    elsif line =~ /gem 'sqlite3'/
      out << "\n"
    else
      out << line
    end
  end
  f.pos = 0
  f.print out.chomp
  f.truncate(f.pos)
end

gem_group :test, :development do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'better_errors'
  gem 'sprockets_better_errors'
  gem 'binding_of_caller'
  gem 'factory_girl_rails'
  gem 'simplecov'
  gem 'database_cleaner'
  gem 'sqlite3'
  gem 'pry'
end

gem_group :production do
  gem 'pg'
  gem 'google-analytics-rails'
  gem 'rails_12factor'
end

gem 'bootstrap-sass', '~> 3.1.1'

# Delete README.rdoc
run 'rm README.rdoc'

# Add template data to README.md
file 'README.md', <<-README.strip_heredoc.chomp
  # #{app_name.split('_').map(&:capitalize).join(' ')}
README

# Add LICENSE
file 'LICENSE', <<-MIT.strip_heredoc.chomp
  The MIT License (MIT)

  Copyright (c) [year] [fullname]

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
MIT

# Set Rails version to 4.1.0.rc1
File.open("Gemfile", "r+") do |f|
  out = ""
  f.each do |line|
    if line =~ /gem 'rails'/
      out << "#{line.gsub(/, '(.*)'/, ', \'4.1.0.rc1\'')}"
    else
      out << line
    end
  end
  f.pos = 0
  f.print out.chomp
  f.truncate(f.pos)
end

# Disable Turbolinks
File.open("Gemfile", "r+") do |f|
  out = ""
  f.each do |line|
    if line =~ /gem 'turbolinks'/
      out << "# #{line}"
    else
      out << line
    end
  end
  f.pos = 0
  f.print out.chomp
  f.truncate(f.pos)
end

File.open("app/assets/javascripts/application.js", "r+") do |f|
  out = ""
  f.each do |line|
    if line =~ /\/\/= require turbolinks/
      out << "// require turbolinks\n"
    else
      out << line
    end
  end
  f.pos = 0
  f.print out.chomp
  f.truncate(f.pos)
end

File.open("app/views/layouts/application.html.erb", "r+") do |f|
  out = ""
  f.each do |line|
    if line =~ /, 'data-turbolinks-track' => true/
      out << "#{line.gsub(", 'data-turbolinks-track' => true", '')}"
    else
      out << line
    end
  end
  f.pos = 0
  f.print out.chomp
  f.truncate(f.pos)
end

# Bundle
system("bundle")

# Generate RSpec files
generate(:"rspec:install")

# Edit spec/spec_helper.rb
File.open("spec/spec_helper.rb", "r+") do |f|
  out = ""
  f.each do |line|
    if line =~ /require 'rspec\/autorun'/
      # add SimpleCov
      out << line
      out << <<-CODE.strip_heredoc
      require 'simplecov'
      SimpleCov.start 'rails'
    CODE
    elsif line =~ /config\.fixture_path/
      # comment out fixtures
      out << "  ##{line[1..-1]}"
    elsif line =~ /config\.use_transactional_fixtures/
      # set transactional fixtures to false
      out << line.sub("true", "false")
    elsif line =~ /RSpec\.configure do/
      # add Database Cleaner
      out << line
      out << <<-CODE.gsub(/^ {6}/, '')
        config.include FactoryGirl::Syntax::Methods

        config.before(:suite) do
          DatabaseCleaner.strategy = :transaction
          DatabaseCleaner.clean_with(:truncation)
        end

        config.before(:each) do
          DatabaseCleaner.start
        end

        config.after(:each) do
          DatabaseCleaner.clean
        end
      CODE
    else
      out << line
    end
  end
  f.pos = 0
  f.print out.chomp
  f.truncate(f.pos)
end

# Make spec/features directory
run('mkdir -p spec/features')
run('touch spec/features/.keep')

# Create feature_helper.rb
file 'spec/feature_helper.rb', <<-CODE.strip_heredoc.chomp
  require 'spec_helper'
  require 'capybara/rails'
CODE

# Setup Guardfile
file 'Guardfile', %q(
  # guard 'rails' do
  #   watch('Gemfile.lock')
  #   watch(%r{^(config|lib)/.*})
  # end


  guard :rspec do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')  { "spec" }

    # Rails example
    watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/(.*)(\.erb|\.haml|\.slim)$})          { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
    watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
    watch('config/routes.rb')                           { "spec/routing" }
    watch('app/controllers/application_controller.rb')  { "spec/controllers" }

    # Capybara features specs
    watch(%r{^app/views/(.+)/.*\.(erb|haml|slim)$})     { |m| "spec/features/#{m[1]}_spec.rb" }

    # Turnip features and steps
    watch(%r{^spec/acceptance/(.+)\.feature$})
    watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$})   { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance' }
  end
).strip.gsub(/^ {2}/, '')

# Set up Google Analytics
environment 'GA.tracker = Rails.application.secrets.google_analytics_code', env: 'production'

File.open("app/views/layouts/application.html.erb", "r+") do |f|
  out = ""
  f.each do |line|
    if line =~ /<%= csrf_meta_tags %>/
      out << "#{line}"
      out << "  <%= analytics_init if Rails.env.production? %>\n"
    else
      out << line
    end
  end
  f.pos = 0
  f.print out.chomp
  f.truncate(f.pos)
end

File.open("config/secrets.yml", "r+") do |f|
  out = ""
  f.each do |line|
    if line =~ /production:/
      out << "#{line}"
      out << "  google_analytics_code: 'YOUR CODE HERE'\n"
    else
      out << line
    end
  end
  f.pos = 0
  f.print out.chomp
  f.truncate(f.pos)
end

#Sset up sprockets_better_errors
environment 'config.assets.raise_production_errors = true', env: 'development'

# Turn on precompile assets in production
File.open("config/environments/production.rb", "r+") do |f|
  out = ""
  f.each do |line|
    if line =~ /config.assets.compile = false/
      out << "  config.assets.compile = true\n"
    else
      out << line
    end
  end
  f.pos = 0
  f.print out.chomp
  f.truncate(f.pos)
end

# Set up Bootstrap
inside('app/assets/stylesheets') do
  run "mv application.css application.css.scss"
end

File.open("app/assets/stylesheets/application.css.scss", "r+") do |f|
  out = ""
  f.each do |line|
    if line =~ /\*= require_self/
      out << "#{line}"
      out << " //= depend_on_asset \"bootstrap/glyphicons-halflings-regular.eot\"\n"
      out << " //= depend_on_asset \"bootstrap/glyphicons-halflings-regular.woff\"\n"
      out << " //= depend_on_asset \"bootstrap/glyphicons-halflings-regular.ttf\"\n"
      out << " //= depend_on_asset \"bootstrap/glyphicons-halflings-regular.svg\"\n"
    elsif line =~ /\*\//
      out << "#{line}"
      out << "@import \"bootstrap\";"
    else
      out << line
    end
  end
  f.pos = 0
  f.print out.chomp
  f.truncate(f.pos)
end

File.open("app/assets/javascripts/application.js", "r+") do |f|
  out = ""
  jquery_count = 0
  f.each do |line|
    if line =~ /\/\/= require jquery/
      jquery_count += 1
      if jquery_count == 1
        out << "//= require bootstrap\n//= require jquery\n//= require jquery_ujs\n"
      end
    else
      out << line
    end
  end
  f.pos = 0
  f.print out.chomp
  f.truncate(f.pos)
end

# Add STACK description file
file 'STACK', <<-STACK.strip_heredoc.chomp
  This generator has set up the following stack:

    1. Testing
      * RSpec
      * Capybara
      * Database Cleaner
      * SimpleCov
      * Guard
    2. Frontend
      * Bootstrap
      * Disabled Turbolinks
      * Google Analytics
      * Precompiled assets in production
    3. Gem groups set up for easy Heroku deployment
      * Postgres will work out of the box. No configuration necessary.

  TODO:
    1. An MIT License file has been created for you
      * Add your name and the year
    2. A README.md file has been started for you
      * Add relavent information and screenshots for your app
    3. Google Analytics is set up to track your app
      * You will need to add your analytics code to `config/secrets.yml`
      * Set up an application on Google Analytics to get this code.
STACK

# Initialize git repository and make initial commit
git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

# TODO: Add ruby 2.1.0 to gemfile