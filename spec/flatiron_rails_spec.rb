require 'spec_helper'

describe 'flatiron-rails generator' do
  context 'heroku' do
    before :all do
      stub(:gets).with("no")
      system("flatiron-rails test-with-heroku")
      system("cd test-with-heroku")
    end

    after :all do
      system("cd .. && rm -rf test-with-heroku")
    end
  end

  context 'ninefold' do
    before :all do
      stub(:gets).with("yes")
      system("flatiron-rails test-with-ninefold")
      system("cd test-with-ninefold")
    end

    after :all do
      system("cd .. && rm -rf test-with-ninefold")
    end
  end
end