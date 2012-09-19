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
  @@instruments = nil   # NORMALEMENT, OBSOLÈTE
                        # C'EST ORCHESTRE.instruments qui contient les
                        # instrument
    
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :octave_defaut
  
  @name       = nil   # Le nom (capitales) du musicien (constante) tel
                      # que défini dans le def-hash @orchestre
                      # @todo: cette propriété ne semble pas être définie
                      # à l'initialisation => tester
  @data       = nil   # Les data telles que définies dans l'orchestre
  @ton        = nil   # La tonalité de la portée. C'est la tonalité du 
                      # morceau, par défaut, sauf pour les instruments
                      # transpositeur (p.e. sax en sib)
  @clef       = nil   # La clé générale pour l'instrument, parmi :
                      # G (sol), F (fa), U3 (ut 3e ligne), 
                      # U4 (ut 4e ligne)
  
  @staff      = nil   # Instance Staff pour la construction de la portée
                      # de l'instrument
  
  @notes      = nil   # La liste Array des notes de l'instrument au 
                      # cours du morceau. Ce sont des instances de LINote
                      # contenant toutes les informations et notamment :
                      # l'octave, la durée
  
  @displayed = nil    # Détermine si l'instrument doit être affiché ou
                      # non (lorsqu'une option le retire)
                      
  def initialize data = nil
    @data       = data
    @notes      = []
    @displayed  = true
    data.each do |prop, value|
      instance_variable_set("@#{prop}", value)
    end unless data.nil?
  end
  
  
  # => Retourne les mesures de l'instrument spécifiées par +params+
  # 
  # Cette méthode est une des méthodes principales de construction de la
  # partition. 
  def mesures first, last = nil
    last ||= first
    # @todo: produire ici une erreur si last est avant first
    
    # Retourner toutes les notes s'il n'y a pas de filtre de mesure
    # puts "@notes: #{@notes.inspect}"
    # @notes contient quelque chose comme : \relative c { a b c }
    return @notes_lilypond if first.nil? && last.nil?
    
    duree_mesure = SCORE::duree_absolue_mesure
    
    position_courante       = 0
    index_mesure            = 1
    linotes_expected        = []
    duree_absolue_last_note = nil
    @notes.each do |linote|
      # Tant qu'on n'a pas atteint la dernière mesure voulue,
      # on prend la linote si on a déjà passé la première mesure voulue
      if index_mesure >= first
        linotes_expected << linote
      end
      duree_note = linote.duree_absolue || duree_absolue_last_note
      position_courante += duree_note
      if position_courante == duree_mesure
        # Une fin de mesure est atteinte avec cette note
        index_mesure      += 1 
        position_courante =  0
        break if index_mesure > last
      end
      duree_absolue_last_note = duree_note
    end
    linotes_expected = LINote::implode linotes_expected
    puts "linotes_expected: #{linotes_expected.inspect}"
    linotes_expected
  end
  alias :measures :mesures
  
  # =>  Retourne l'ensemble des notes de l'instrument, sous forme d'un
  #     Array d'objets LINote
  def explode
    @exploded ||= LINote::explode staff_content
  end
  
  # -------------------------------------------------------------------
  #   Méthodes de définition de la partition de l'instrument
  # -------------------------------------------------------------------
  
  # => Ajoute l'élément +some+ à la partition de l'instrument
  # 
  # @param  some   
  #         Peut être :
  #         - String des notes à ajouter, p.e. "c2 bb c4 d d d"
  #         - Un motif (instance Motif)
  #         - Un hash complexe pouvant définir dans quelles mesures il
  #           faut ajouter la séquence (rare).
  # @param  params    Hash contenant des valeurs pour modifier les 
  #                   motifs ou les accords (à commencer par la durée,
  #                   spécifiée par :duree => <duree lilypond>)
  def add some, params = nil
    return unless @displayed
    case some.class.to_s
    when 'String' then  add_as_string some, params
    when 'Motif'  then  add_as_motif  some, params
    when 'Chord'  then  add_as_chord  some, params
    when 'Hash'   then raise "Les hash ne sont pas encore traités"
    when 'Proc'   then fatal_error(:type_procedure_unexpected)
    else
      fatal_error(:type_ajout_unknown, :type => some.class.to_s)
    end
  end
  alias :<< :add
  
  # =>  Insert les notes
  # 
  # @param  notes   Array des instances LINotes à insérer dans les
  #                 notes de l'instrument.
  # 
  # @note:  C'est la méthode finale de la suite :
  #           add <something> (ci dessus)
  #           add_<suivant type something> (p.e. "add_as_motif")
  #           add_notes 
  # 
  # @note:  C'est dans cette méthode qu'on va gérer les delta pour faire
  #         le bon raccord octave avec les notes précédentes.
  # 
  def add_notes linotes, params = nil
    
    return if linotes.nil? || linotes.empty?
    
    # Gestion du raccord avec note précédente
    # ----------------------------------------
    # @principe:    Le principe est simple : si la dernière note n'a
    #               pas la même octave que la première note des nouvelles
    #               notes, il faut modifier le delta de la première des
    #               nouvelles notes.
    unless @notes.empty?
      note_last     = @notes.last.note
      octave_last   = @notes.last.octave( treat_accord = true )
      note_newune   = linotes.first.note
      octave_newune = linotes.first.octave
    end
    
    # Traitement des paramètres
    # -------------------------
    # @rappel:  les paramètres peuvent tout modifier dans une donnée,
    #           comme l'octave, la durée, etc.
    # @note:    on les ajoute seulement à la première note (peut-être
    #           que ça sera différent plus tard) 
    params.each { |p, v| @notes.first[p] = v } unless params.nil?
    @notes = @notes + linotes
  end
  
  # => Ajoute la chose comme liste de notes
  # 
  # La méthode transforme le string +str+ en liste de LINotes pour pouvoir
  # l'insérer dans la suite des notes de l'instrument.
  # 
  # @note:    Transforme les italiennes et altérations normales en 
  #           lilypond
  # 
  def add_as_string str, params = nil
    suite_str = LINote::to_llp(str)
    add_notes LINote::explode suite_str, params
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
  
  # =>  Définit @notes_lilypond, suite de notes au format lilypond
  # 
  # @principe: la méthode passe en revue toutes les LINotes de @notes
  # et les ajoute.
  # 
  # @return   Le string fabriqué, prêt à être mis dans le score lilypond
  # 
  # @note     Ne commence pas par « \relative ... » (cf. ci-dessous)
  # 
  # @note     Je n'ai plus besoin de traiter l'octave ici puisqu'il est
  #           maintenant traité au bon endroit, c'est-à-dire dans la
  #           première marque relative.
  # 
  def notes_to_llp
    return "" if @notes.empty?
    @notes_lilypond = ""
    @notes.each { |ln| @notes_lilypond << ln.to_llp }
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

    # @todo: ci-dessous, on pourra retirer le mark_relative, qui
    # ne sert à rien
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
  # @notes: si un filtre des mesures est appliquées, on l'utilise
  def staff_content
    mesures SCORE::from_mesure, SCORE::to_mesure
  end
  
  # => Return la marque "relative c..."
  # 
  def mark_relative
    octave =  unless @notes.empty?
                @notes.first.octave
              else
                @octave_defaut || 4
              end
    Score::mark_relative( octave )
  end
  # 
  # # => Retourne un accord (instance Accord) de l'instrument
  # def accord params = nil
  #   Chord::new params
  # end
  # alias :chord :accord
  # 
  # # => Retourne les accords de l'instrument spécifiés par +params+
  # def accords params
  #   @chords ||= {}
  # end
  # alias :chords :accords
  # 
  # # => Retourne un motif (instance Motif) de l'instrument
  # def motif params = nil
  #   Motif::new params
  # end
  # # => Retourne les motifs de l'instrument spécifiés par +params+
  # def motifs params
  #   @motifs ||= {}
  # end
  # 
  # # => Retourne une mesure (instance Mesure) de l'instrument
  # def mesure params = nil
  #   Measure::new params
  # end
  # alias :measure :mesure
  # 
end