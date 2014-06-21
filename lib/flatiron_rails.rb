class FlatironRails

  FLATIRON_ROOT = File.expand_path('../', File.dirname(__FILE__))
  def self.run
    if ['-v', '--version'].include?(ARGV[0])
      puts <<-VERSION.gsub(/^ {6}/, '')
      Flatiron Rails 1.0.8
      VERSION
    elsif ARGV[0].nil? || ['-h','--help'].include?(ARGV[0]) || ARGV[0] != "new" || ARGV[2]
      puts <<-HELP.gsub(/^ {6}/, '')
      Usage:
        flatiron-rails new <app_name>
      HELP
    else
      system("rails new #{ARGV[1]} -Tm #{FLATIRON_ROOT}/templates/flatiron.rb")
    end
  end
  
end