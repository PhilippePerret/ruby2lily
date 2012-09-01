# 
# Classe principale Liby
# 
# C'est la classe qui chapeaute tout le processus
# 
class Liby
  USAGE   = "@usage:\n\t$ ./ruby2lily.rb <path/to/score/ruby> <options>"
  ERRORS  = {
    :arg_path_file_ruby_needed  => "Le path du score ruby doit être donné en premier argument.\n#{USAGE}",
    :arg_score_ruby_unfound     => "Le score '\#{path}' est introuvable",
    :orchestre_undefined        => "Le score doit définir l'orchestre (@orchestre = ...)",
    
    :path_lily_undefined        => "Impossible de définir le chemin au fichier Lilypond…"
  }
  
  @@path_ruby_score = nil   # Le path au fichier du score ruby user
  @@path_lily_file  = nil   # path au fichier lilypond
  @@path_pdf_file   = nil   # Path au fichier pdf du score
 
  class << self

    # =>  Produit une erreur fatale d'identifiant +id_err+ avec les
    #     variables +params+ et exit le programme
    def fatal_error id_err, params = nil
      err = error( id_err, params )
      puts err.as_red
      exit
    end
    
    # =>  Formate l'erreur d'identifiant +id_err+ avec les arguments
    #     +params+ et renvoie l'erreur:String formatée.
    def error id_err, params = nil
      err = if ERRORS.has_key? id_err
              ERRORS[id_err.to_sym]
            else id_err end
              
      params.each do |arg, val|
        err = err.gsub(/\#\{#{arg}\}/, val)
      end unless params.nil?
      err
    end

    # => Analyse de la ligne de commande (ses arguments ARGV)
    # @produit:
    #   @@path_score      Le chemin d'accès au score ruby
    # 
    def analyze_command_line
      tested = ARGV[0]
      fatal_error :arg_path_file_ruby_needed if tested.nil?
      pscore = find_path_score tested
      fatal_error(:arg_score_ruby_unfound, :path => tested) if pscore.nil?
      @@path_ruby_score = pscore
    end
    
    # -------------------------------------------------------------------
    #   Conversion Ruby -> Lilypond
    # -------------------------------------------------------------------

    # Méthode principale qui convertit le score ruby spécifié en
    # ligne de commande en un fichier lilypond (.ly) conforme
    # @return
    #   true en cas de succès
    #   nil et lève une erreur en cas d'échec
    def score_ruby_to_score_lilypond
      begin
        Score::Sheet::build
      rescue Exception => e
        fatal_error e.message
      else
        true
      end
    end
    
    # => Message de fin de conversion
    def end_conversion
      # @todo: pour le moment :
      puts "Fichier converti avec succès".as_blue
      true
    end
    
    # -------------------------------------------------------------------
    # Méthodes paths
    # -------------------------------------------------------------------
    # => Retourne le chemin d'accès complet au score ruby
    def path_ruby_score
      @@path_ruby_score
    end
    def path_lily_file
      @@path_lily_file ||= path_of_extension( 'ly' )
    end
    def path_pdf_file
      @@path_pdf_file ||= path_of_extension( 'pdf' )
    end
    # => Retourne le path courant avec l'extension +extension+
    # 
    # Cette méthode part du principe que tous les fichiers d'un même
    # score (partition) possède le même path, à la différence de 
    # l'extension près.
    def path_of_extension extension
      return nil if path_ruby_score.nil?
      folder  = File.dirname(@@path_ruby_score)
      affixe  = File.basename(@@path_ruby_score, '.rb')
      File.join(folder, "#{affixe}.#{extension}")
    end
  end # / class << self


  private
  
    # => Retourne le path du score trouvé ou nil
    # @param  path_rel    Le path relatif du score, qui peut être donné:
    #                     - en chemin absolu
    #                     - à partir du dossier où est jouée la commande
    #                     - à partir du dossier de l'utilisateur
    #                     - à partir du dossier lilypond-ruby
    # @return
    #   -> le chemin d'accès absolu si le fichier est trouvé
    #   -> nil si le fichier n'est pas trouvé
    def self.find_path_score path_rel
      path_rel += '.rb' unless path_rel.end_with? '.rb'
      path = File.expand_path(path_rel)
      return path if File.exists? path
      path = File.expand_path(File.join('.', path_rel))
      return path if File.exists? path
      path = File.expand_path(File.join('~', path_rel))
      return path if File.exists? path
      path = File.expand_path(File.join(BASE_LILYPOND, path_rel))
      return path if File.exists? path
      nil
    end

end