class FlatironRails

  FLATIRON_ROOT = File.expand_path('../', File.dirname(__FILE__))
  def self.run
    if ARGV[0].nil? || ['-h','--help'].include?(ARGV[0]) || ARGV[1]
      puts <<-HELP.gsub(/^ {6}/, '')
      Usage:
        flatiron-rails <app_name>
      HELP
    elsif ['-v', '--version'].include?(ARGV[0])
      puts <<-VERSION.gsub(/^ {6}/, '')
      flatiron-rails v0.0.14
      VERSION
    else
      system("rails new #{ARGV[0]} -Tm #{FLATIRON_ROOT}/templates/flatiron.rb")
    end
  end
  
end