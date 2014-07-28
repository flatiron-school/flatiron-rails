class PostgresChecker
  def self.check
    new.check
  end

  def check
    if !brew_installed?
      puts "You must have Homebrew installed."
      exit
    else
      if !postgres_installed?
        install_postgres
      end
    end
  end

  def brew_installed?
    !`which brew`.empty?
  end

  def postgres_installed?
    !`brew ls --versions postgresql`.empty?
  end

  def install_postgres
    system('brew install postgresql')
  end
end
