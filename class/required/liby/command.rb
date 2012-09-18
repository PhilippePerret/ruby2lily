# 
# Sous-classe Liby::Command
# 
# qui gère les commandes
# 
require 'fileutils'
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
      path  = File.join(BASE_RUBY2LILY, 'HELP.md')
      texte = File.read(path)
      puts "\n\n#{texte}"
      texte # pour les tests
    end
    
    # => Renvoie la version et des informations en console
    def run_version
      require File.join(BASE_RUBY2LILY, 'VERSION.rb')
      version = "- version: #{RUBY2LILY_VERSION}"
      auteur  = "- author: Philippe Perret <philippe.perret@yahoo.fr" 
      github  = "- github: https://github.com/PhilippePerret/ruby2lily"
      texte = "\nruby2site #{version}\n#{auteur}\n#{github}\n\n"
      
      puts texte
      texte # pour tests
    end
    
    # => Créer une nouvelle configuration de partition
    # 
    # @note: les éléments se trouvent dans `data/model`
    def run_new
      begin
        score_name      = Liby::parameters.first
        puts "Création de la configuration de partition « #{score_name} »"
        titre_score     = Liby::score_name_to_title score_name
        dossier_courant = File.expand_path('.')
        dossier_score   = File.join(dossier_courant, score_name)
        raise 'folder_score_already_exists' if File.exists?(dossier_score)
        
        # Création du dossier score et tous ses dossiers/fichiers
        Dir.mkdir( dossier_score, 0777 )
        folder_model = Liby::path_folder_model
        Dir["#{folder_model}/**/*"].each do |file|
          new_path = file.sub(/#{folder_model}/, dossier_score)
          if File.directory?( file )
            Dir.mkdir( new_path, 0777 )
          else
            FileUtils::cp file, new_path
          end
        end
        
        # On règle le titre du score
        # ---------------------------
        path_score = File.join(dossier_score, 'score.rb')
        code_score = File.read( path_score )
        code_score = code_score.gsub( /TITRE_MORCEAU/, titre_score )
        File.open(path_score, 'wb'){ |f| f.write code_score }
        
        puts "Le dossier score a été fabriqué"
        true
      rescue Exception => e
        fatal_error(e.message)
      end
    end
  end
  
end