require 'spec_helper'

describe 'flatiron-rails generator' do
  context 'heroku' do
    before :all do
      system("flatiron-rails test-with-heroku")
    end

    after :all do
      system("rm -rf test-with-heroku")
    end
  end

  context 'ninefold' do
    before :all do
      system("flatiron-rails test-with-ninefold")
    end

    after :all do
      system("rm -rf test-with-ninefold")
    end
  end
end