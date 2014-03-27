# Flatiron Rails

## Description

A Ruby on Rails application generator that sets up the default Flatiron School stack. This stack includes:

1. Testing
  * RSpec
  * Capybara
  * Database Cleaner
  * SimpleCov
  * Guard
2. Frontend
  * Disabled Turbolinks
  * Bootstrap
  * Google Analytics
  * Precompiled assets in production
3. Deployment
  * Options to set up gem groups for either Heroku or Ninefold deployment
  * Automatically installs Heroku command line tools if they are missing
  * For Heroku deployment, adds bin files for two-line setup and deploy
4. Optional Devise setup

## Usage

`flatiron-rails new <app_name>`