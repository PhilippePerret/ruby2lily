# 
# Sous-classe Liby::Command
# 
# qui gère les commandes
# 
require 'liby'

class Liby::Command
  
  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------
  class << self
    
    def run commande, params = nil
      eval("run_#{commande}")
    end
    
    # -------------------------------------------------------------------
    #   Launchers de commande
    # -------------------------------------------------------------------

    # => Affiche l'aide de l'application
    def run_help
      path  = File.join(BASE_LILYPOND, 'HELP.md')
      texte = File.read(path)
      puts "\n\n#{texte}"
      texte # pour les tests
    end
    
    # => Renvoie la version et des informations en console
    def run_version
      require File.join(BASE_LILYPOND, 'VERSION.rb')
      version = "- version: #{RUBY2LILY_VERSION}"
      auteur  = "- author: Philippe Perret <philippe.perret@yahoo.fr" 
      github  = "- github: https://github.com/PhilippePerret/ruby2lily"
      texte = "\nruby2site #{version}\n#{auteur}\n#{github}\n\n"
      
      puts texte
      texte # pour tests
    end
  end
  
end