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
      :hash_required              => "un hash est requis",
      :command_line_empty         => "`ruby2site` doit s'appeler avec des arguments." \
                                     << "Utilisez `ruby2site -h` pour obtenir de l'aide.",
      :unknown_option             => "L'option `\#{option}` est inconnue…",
      :arg_path_file_ruby_needed  => "Le path du score ruby doit être donné en premier argument.\n#{USAGE}",
      :arg_score_ruby_unfound     => "Le score '\#{path}' est introuvable",
      :orchestre_undefined        => "Le score doit définir l'orchestre (@orchestre = ...)",
    
      :path_lily_undefined        => "Impossible de définir le chemin au fichier Lilypond…",
      :lilyfile_does_not_exists   => "Le fichier Lilypond du score n'existe pas…",
      
      # === Méthodes générales === #
      :bad_params_in_crochet      => "Mauvais argument envoyés dans `[...]'",
      :bad_type_for_args          => "Mauvais types pour les arguments (attendus : \#{good}, reçus : \#{bad})",
      :too_much_parameters_to_crochets  => "Trop de paramètres envoyés dans `[]' (2 max)",
      :bad_class_in_parameters_crochets => "Mauvais argument dans `[...]' (seulement nombre, string de durée ou Hash)",
 
      :cant_add_this              => "Un objet de type \#{classe} ne peut être ajouté…",
      
      # === Erreurs durée === #
      :bad_value_duree            => "La durée \#{bad} est invalide !",
      
      # === Définition du score ===
      :title_not_string           => "Le titre doit être une chaine de caractères",
      :time_invalid               => "La signature de temps (@time) est invalide" \
                                     << "(elle devrait être sous la forme « xx/xx »)",
      :key_invalid                => "La clé (@key/@tonalite) est mal définie ('\#{bad}')" \
                                    << "(elle devrait être une valeur parmi #{LINote::TONALITES.keys.join(', ')}).",
      
      # ==== Motif ==== #
      :invalid_arguments_pour_motif => "Les arguments pour définir le motif sont invalides… (\#{raison} dans \#{args})",
      :invalid_motif              => "Le motif fourni ('\#{bad}') est invalide.",
      :bad_argument_for_as_motif  => "L'argument `\#{bad}' est invalide pour la méthode :as_motif",
      :invalid_duree_notes        => "La durée pour les notes est invalides",
      :cant_add_any_to_motif      => "Un objet de type \#{classe} ne peut être ajouté à un motif…",
      :unable_to_find_first_note_motif  => "Impossible de trouver la première note dans le motif \#{notes}…",
      :unable_to_find_last_note_motif   => "Impossible de trouver la dernière note dans le motif \#{notes}…",
      :motif_cant_be_surslured      => "Aucune liaison ne peut être ajoutée à \#{motif} (déjà lié) !",
      :motif_legato_cant_be_slured  => "Un motif legato ne peut être sluré…",
      
      # ==== Note ==== #
      :bad_args_for_join_linote   => "Les arguments pour la méthode LINote::join sont invalides",
      
      :fin_fin_fin_fin_fin => ''
    }
    
    OPTION_LIST = {
      'version'   => {:hname => "Version de ruby2lily", :lily => false},
      'v'         => 'version',
      'format'    => {:hname => "Format du fichier de sortie (LilyPond)",
                      :lily => true},
      'f'         => 'format',
      'help'      => {:hname => "Aide ruby2lily", :lily => false},
      'h'         => 'help'
    }
    
    # Liste des options transformées en command ("options-commandes")
    OPTION_COMMAND_LIST = {
      'version' => true,
      'help'    => true
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
  
  @@command           = nil   # La commande à jouer (if any)
  @@options           = nil   # Options de la ligne de commande
  @@parameters        = nil   # Tous les paramètres de la ligne de
                              # commande (dont la commande ou le path
                              # du fichier à lilyponder).
  
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
      err = if ERRORS.has_key? id_err.to_sym then ERRORS[id_err.to_sym]
            else id_err end
      detemp( err, params )
    end

    # => Analyse de la ligne de commande (ses arguments ARGV)
    # 
    # @produit:
    # 
    #   @@options         Les options relevées
    #   @@parameters      Les paramètres (dont le path du score if any)
    #   @@path_score      Le chemin d'accès au score ruby
    # 
    def analyze_command_line
      tested = ARGV[0]
      @@options         = {}
      @@parameters      = []
      @@command         = nil
      @@path_ruby_score = nil
      # On passe en revue tous les membres de la ligne de commande
      ARGV.each do |membre|
        if membre.start_with? '-'
          treat_as_option membre
        elsif @@command.nil? && COMMAND_LIST.has_key?( membre.to_sym )
          @@command = membre.to_s
        else
          @@parameters << membre
        end
      end
      
      # On regarde si la ligne de commande ne contient aucune erreur
      # Toute erreur trouvée est fatale
      treat_errors_command_line
      
    end
    
    # => Analyse l'option de ligne de commande
    def treat_as_option doption
      option = nil
      valeur = nil
      if doption.start_with? '--'
        doption.gsub(/^--([^=]+)=?(.*)?$/){
          option = $1
          valeur = $2
        }
      else
        option_courte = doption[1..1]
        option = OPTION_LIST[option_courte]
        fatal_error(:unknown_option, :option => option_courte) if option.nil?
        valeur = doption[2..-1]
      end
      # Est-ce que c'est une "option-command"
      if OPTION_COMMAND_LIST.has_key? option
        @@command = option
      else
        @@options = @@options.merge option => valeur
      end
    end
    
    # =>  Méthode qui vérifie que la ligne de commande est correcte et
    #     lève une erreur fatale dans le cas contraire
    # 
    # @note: tous les éléments de la ligne de commande sont contenus dans
    #         @@options (les options)
    #         @@parameters (les paramètres — dont le(s) path(s))
    #         @@command (si une commande est passée)
    def treat_errors_command_line
      
      # ruby2lily ne peut s'appeler seul
      fatal_error(:command_line_empty) if \
        @@command == nil \
        && @@parameters.empty? \
        && @@options.empty?
        
      # Les options sont-elles valides
      # @note: une première vérification a été faite sur les options
      # courtes, qui ont toutes été transformées en options longues (--)
      @@options.each do |option, valeur|
        fatal_error(:unknown_option, :option => option) \
          unless OPTION_LIST.has_key? option
      end
      
      # Si c'est un lilypondage qui est demandé (aucune option contraire)
      # le score passé en premier argument doit exister
      if !command? # @todo: + vérifier options
        path_score = @@parameters.first
        fatal_error :arg_path_file_ruby_needed if path_score.nil?
        pscore = find_path_score path_score
        fatal_error(:arg_score_ruby_unfound, :path => path_score) if pscore.nil?
        @@path_ruby_score = pscore
      end
      
    end
    
    # -------------------------------------------------------------------
    #   Traitement des commandes
    # -------------------------------------------------------------------
    
    # => Joue la commande trouvée dans la ligne de commande
    def run_command
      Liby::Command::run @@command
    end
    
    # =>  Retourne true si c'est une commande qui est demandée, pas la
    #     conversion du fichier ruby
    def command?
      @@command != nil
    end
    
    # -------------------------------------------------------------------
    #   Contrôle des types/classes
    # -------------------------------------------------------------------
    
    # =>  Lève une erreur fatale si un des éléments passés en argument
    #     n'est pas un Motif
    def raise_unless_motif *elements
      raise_unless_args_of_class elements, Motif
    end
    # =>  Lève une erreur fatale si un des éléments passés en argument
    #     n'est pas une LINote
    def raise_unless_linote *elements
      raise_unless_args_of_class elements, LINote
    end
    # =>  Méthode générale pour les méthodes précédentes
    def raise_unless_args_of_class elements, classe
      elements.each do |element|
        next if element.class == classe
        fatal_error(:bad_type_for_args, 
                    :good => classe.to_s, :bad => element.class)
      end
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
      return nil if command?
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