# 
# Classe principale Liby
# 
# C'est la classe qui chapeaute tout le processus
# 
require 'String'
require 'linote'

class LibyError < StandardError
end

class Liby
  unless defined?(Liby::USAGE)
    USAGE   = "@usage:\n\t$ ./ruby2lily.rb <path/to/score/ruby> <options>"
    ERRORS  = {
      :arg_path_file_ruby_needed  => "Le path du score ruby doit être donné en premier argument.\n#{USAGE}",
      :arg_score_ruby_unfound     => "Le score '\#{path}' est introuvable",
      :orchestre_undefined        => "Le score doit définir l'orchestre (@orchestre = ...)",
    
      :path_lily_undefined        => "Impossible de définir le chemin au fichier Lilypond…",
      :lilyfile_does_not_exists   => "Le fichier Lilypond du score n'existe pas…",
      
      # === Définition du score ===
      :title_not_string           => "Le titre doit être une chaine de caractères",
      :time_invalid               => "La signature de temps (@time) est invalide " +
                                      "(elle devrait être sous la forme « xx/xx »)",
      :key_invalid                => "La clé (@key/@tonalite) est mal définie ('\#{bad}') " +
                                    "(elle devrait être une valeur parmi #{LINote::TONALITES.keys.join(', ')}).",
      
      
      :fin_fin_fin_fin_fin => ''
    }
    
    # table de conversion des signes ruby vers lilypond
    SIGN_RUBY_TO_SIGN_LILY = {
      'b' => 'es', 'bb' => 'eses', '#' => 'is', '##' => 'isis'
    }
  
    COMMAND_LIST = {
      :generate => {}
    }
  end # / si les constantes sont déjà définies (tests)
  
  @@path_ruby_score   = nil   # Le path au fichier du score ruby user
  @@path_lily_file    = nil   # path au fichier lilypond
  @@path_pdf_file     = nil   # Path au fichier pdf du score
  @@path_affixe_file  = nil   # Affixe (utile pour commande lilypond)
  
  @@is_commande       = nil   # Mis à true si c'est une commande
  @@options           = nil   # Options de la ligne de commande
  
  class << self

    # =>  Produit (en console) une erreur fatale d'identifiant +id_err+
    #     avec les variables +params+ et exit le programme
    def fatal_error id_err, params = nil
      err = error( id_err, params )
      puts err.to_s.as_red
      if err === true
        begin
          raise
        rescue Exception => e
          debug "\nERREUR FATAL_ERROR (err = true):\n#{e.message}"
        end
      end
      raise SystemExit, err 
    end
    
    # =>  Formate l'erreur d'identifiant +id_err+ avec les arguments
    #     +params+ et renvoie l'erreur:String formatée.
    def error id_err, params = nil
      err = if ERRORS.has_key? id_err then ERRORS[id_err.to_sym]
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
      @@is_commande = !tested.nil? && COMMAND_LIST.has_key?( tested.to_sym )
      options_from_command_line
      if commande?
        Liby::Command::new(tested).run
      else
        fatal_error :arg_path_file_ruby_needed if tested.nil?
        pscore = find_path_score tested
        fatal_error(:arg_score_ruby_unfound, :path => tested) if pscore.nil?
        @@path_ruby_score = pscore
      end
    end
    
    # => Relève les options de la ligne de commande
    def options_from_command_line
      options = []
      ARGV.each do |membre|
        options << membre if membre.start_with? '-'
      end
      options = nil if options.empty?
      @@options = options
    end
    
    # =>  Retourne true si c'est une commande qui est demandée, pas la
    #     conversion du fichier ruby
    def commande?
      @@is_commande == true
    end
    
    # -------------------------------------------------------------------
    #   Traitement des notes et signes envoyés par ruby
    # -------------------------------------------------------------------
    
    # =>  Return +notes_ruby+ en remplaçant les "b" par des "es" et les
    #     "#" par des "is"
    # @param  notes_ruby    Les notes ruby, en string ("c eb d#") ou
    #                       ou Array (["c", "eb", "d#"])
    def notes_ruby_to_notes_lily notes_ruby
      is_array = notes_ruby.class == Array
      notes_ruby = notes_ruby.join(' • ') if is_array
      notes_lily = notes_ruby.gsub(/\b([a-g])([b#]{1,2})/){
        $1 << Liby::SIGN_RUBY_TO_SIGN_LILY[$2]
      }
      notes_lily = notes_lily.split(' • ') if is_array
      notes_lily
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
      return nil if commande?
      begin
        Score::Sheet::build
      rescue Exception => e
        dbg "### Backtrace de l'erreur :\n#{e.backtrace.join("\n")}" if defined? DEBUG
        fatal_error e.message # exit le programme
      else
        true
      end
    end
    
    # => Produit le pdf et l'ouvre
    def generate_pdf
      begin
        raise( :lilyfile_does_not_exists ) unless File.exists?( path_lily_file )
        `lilypond --output='#{path_affixe_file}' '#{path_lily_file}'`
        `open  '#{path_pdf_file}'`
      rescue Exception => e
        fatal_error e.message
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
    def path_affixe_file
      @@path_affixe_file ||= path_of_extension
    end
    # => Retourne le path courant avec l'extension +extension+
    # 
    # Cette méthode part du principe que tous les fichiers d'un même
    # score (partition) possède le même path, à la différence de 
    # l'extension près.
    def path_of_extension extension = ""
      return nil if path_ruby_score.nil?
      folder  = File.dirname(@@path_ruby_score)
      affixe  = File.basename(@@path_ruby_score, '.rb')
      extension = ".#{extension}" unless extension == ""
      File.join(folder, "#{affixe}#{extension}")
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
      path_rel = "#{path_rel}.rb" unless path_rel.end_with? '.rb'
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