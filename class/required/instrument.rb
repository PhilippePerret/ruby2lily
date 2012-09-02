# 
# Class Instrument
# 
# Pour créer et gérer les instruments de la partition.
# 
# @rappel: un instrument doit toujours être défini en capital pour 
# pouvoir être utilisé partout dans le programme.
# 
class Instrument
  
  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------

  unless defined?(Instrument::TYPES)
    # Les types d'instrument
    # @todo: il faudrait qu'ils y soient tous, puisqu'un contrôle est
    # effectué ET que chaque instrument doit répondre à sa classe.
    # @todo: peut-être serait-il possible d'utiliser une même classe
    # pour plusieurs instruments, comme par exemple la portée piano pour
    # la harpe et le xylophone.
    TYPES = {
      :Voice    => {},
      :Cuivre   => {},
      :Strings  => {},
      :Piano    => {},
      :Cello    => {},
      :Guitar   => {},
      :Bass     => {},
      :Drums    => {}
    }
  end
  # -------------------------------------------------------------------
  #   La classe
  # -------------------------------------------------------------------
  @@instruments = nil       # La liste des instruments (instances)
  
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  @name       = nil   # Le nom (capitales) du musicien (constante) tel
                      # que défini dans le def-hash @orchestre
  @data       = nil   # Les data telles que définies dans l'orchestre
  @ton        = nil   # La tonalité de la portée. C'est la tonalité du 
                      # morceau, par défaut, sauf pour les instruments
                      # transpositeur (p.e. sax en sib)
  @clef       = nil   # La clé générale pour l'instrument, parmi :
                      # G (sol), F (fa), U3 (ut 3e ligne), 
                      # U4 (ut 4e ligne)
  
  @staff      = nil   # Instance Staff pour la construction de la portée
                      # de l'instrument
  
  @notes      = nil   # La liste String des notes de l'instrument au 
                      # cours du morceau
                      
  def initialize data = nil
    @data   = data
    @notes  = ""
    data.each do |prop, value|
      instance_variable_set("@#{prop}", value)
    end unless data.nil?
  end
  
  # => Retourne un accord (instance Accord) de l'instrument
  def accord params = nil
    Chord::new params
  end
  alias :chord :accord
  
  # => Retourne les accords de l'instrument spécifiés par +params+
  def accords params
    @chords ||= {}
  end
  alias :chords :accords
  
  # => Retourne un motif (instance Motif) de l'instrument
  def motif params = nil
    Motif::new params
  end
  # => Retourne les motifs de l'instrument spécifiés par +params+
  def motifs params
    @motifs ||= {}
  end
  
  # => Retourne une mesure (instance Mesure) de l'instrument
  def mesure params = nil
    Measure::new params
  end
  alias :measure :mesure
  
  # => Retourne les mesures de l'instrument spécifiées par +params+
  def mesures params
    
  end
  alias :measures :mesures
  
  # -------------------------------------------------------------------
  #   Méthodes de définition de la partition de l'instrument
  # -------------------------------------------------------------------
  
  # => Ajoute l'élément +some+ à la partition de l'instrument
  # 
  # @param  some   
  #         Peut-être :
  #         - String des notes à ajouter, p.e. "c2 bb | c4 d d d"
  #         - Un motif (instance Motif)
  #         - Un hash complexe pouvant définir dans quelles mesures il
  #           faut ajouter la séquence (rare).
  # @param  params    Hash contenant des valeurs pour modifier les 
  #                   motifs ou les accords (à commencer par la durée,
  #                   spécifiée par :duree => <duree lilypond>)
  def add some, params = nil
    case some.class.to_s
    when 'String' then  add_as_string Liby::notes_ruby_to_notes_lily(some)
    when 'Motif'  then  add_as_motif  some, params
    when 'Chord'  then  add_as_chord  some, params
    when 'Hash'   then raise "Les hash ne sont pas encore traités"
    else
      raise fatal_error(Instrument::ERRORS[:type_ajout_unknown])
    end
  end
  alias :<< :add
  
  # => Ajoute la chose comme liste de notes
  def add_as_string str
    @notes = "#{@notes} #{str}".strip
  end
  # => Ajoute la chose comme accord
  # @param  chord     Instance Chord de l'accord
  # @param  duree     Durée (lilypond) optionnelle
  # 
  # @todo: des vérifications de la validaté des paramètres
  def add_as_chord chord, params = nil
    params ||= {}
    n = chord.with_duree(params[:duree])
    add_as_string n
  end
  
  # => Ajoute la chose comme motif
  # @param  motif     Instance Motif du motif
  # @param  duree     Durée (lilypond) optionnelle
  # 
  # @todo: des vérifications de la validaté des paramètres
  def add_as_motif motif, params = nil
    n = motif.to_s
    unless params.nil? || params[:duree].nil?
      n = "#{n}#{params[:duree]}"
    end
    add_as_string n
  end
  
  # -------------------------------------------------------------------
  #   Méthodes de construction du score Lilypond
  # -------------------------------------------------------------------

  # => Return le code lilypond pour l'instrument (hors accolades)
  # 
  # @param  params    Les paramètres (non utilisés encore, mais à 
  #                   l'avenir, permettra par exemple de définir les
  #                   mesures à prendre)
  # 
  # @note: le code renvoyé est sans accolades, il est donc ajouté
  # "{" et "}" autour du retour lorsqu'il y a plusieurs instruments par
  # exemple.
  # @todo: dans l'avenir, c'est cette méthode ou équivalente dans chaque
  # type d'instrument qui devra le faire, pour pouvoir ajouter des
  # définitions.
  # -------------------------------------------------------------------
  # @principe
  #   On passe en revue chaque mesure de l'instrument et on crée le
  #   code.
  # -------------------------------------------------------------------
  def to_lilypond params = nil
    @staff = Staff::new(
                        :clef         => @clef, 
                        :tempo        => SCORE.tempo, 
                        :base_tempo   => SCORE.base_tempo,
                        :octave_clef  => @octave_clef
                        )

    "\\new Staff {"                                   \
    << "\n\t\\#{mark_relative} {"                     \
    << "\n#{staff_header}".gsub(/\n/, "\n\t")         \
    << "\n#{staff_content}".gsub(/\n/, "\n\t")[1..-1] \
    << "\n\t}\n}"
  end
  
  # => Return l'entête de la portée (clé, tempo, signature)
  def staff_header
    key     = @staff.mark_key
    tempo   = @staff.mark_tempo
    mkey    = key.nil? ? "" : key
    mtempo  = tempo.nil? ? "" : tempo

    # Code retourné : 
    @staff.mark_clef    << "\n"  \
    << @staff.mark_time << "\n"  \
    << mkey << mtempo
  end
  
  # => Return le contenu des notes de l'instrument
  # 
  # @note : pour le moment, on ne fait que retourner les notes mémorisées
  # mais à l'avenir un traitement plus sérieux devra peut-être être fait.
  def staff_content
    @notes
  end
  
  # => Return la marque "relative c..."
  # 
  # Cette méthode est la méthode par défaut, elle doit être
  # définie dans l'instrument s'il en possède une autre
  def mark_relative
    "relative c''"
  end
end