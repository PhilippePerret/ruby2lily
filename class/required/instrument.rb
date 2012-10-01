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
    
  
  # => Retourne le code pour afficher les numéros de mesures
  # 
  # @note:  Ce code doit être inséré dans chaque portée pour pouvoir
  #         fonctionner (je n'ai pas réussi à faire autrement, mais
  #         il serait bien de pouvoir indiquer ça seulement dans
  #         une définir de `Score', car ça multiplie le code alors 
  #         que l'affichage ne se fait que sur le premier instrument.
  #         Hé bien justement, n'inscrire ce code que sur le premier).
  # 
  # @param    first_measure_number  
  #           Numéro de première mesure (quand extrait)
  # 
  # @return   Le code à insérer dans le début de la partition de
  #           l'instrument. Pour le moment, les numéros sont inscrits
  #           en gros, dans un rond, toutes les deux mesures.
  #           @TODO: pouvoir définir mieux l'affichage des numéros.
  # 
  # @note     Le `\bar ""' est obligatoire pour pouvoir afficher le
  #           numéro de la première mesure.
  # 
  def self.code_show_bar_numbers first_measure_number = nil
    return "" if first_measure_number.nil?
    
    # Ajouter ça si on veut que ce soit dans un rond :
    # \\override Score.BarNumber #'stencil
    #     = #(make-stencil-circler 0.1 0.25 ly:text-interface::print)

    <<-EOS
    
    \\override Score.BarNumber #'break-visibility = #end-of-line-invisible
    \\set Score.barNumberVisibility = #all-bar-numbers-visible
    \\set Score.currentBarNumber = ##{first_measure_number}
    \\set Score.barNumberVisibility = #(every-nth-bar-number-visible 2)
    \\override Score.BarNumber #'font-size = #2
		\\bar ""
	  
	  EOS
  end
  
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :name, :octave_defaut
  
  @name       = nil   # Le nom (capitales) du musicien (constante) tel
                      # que défini dans le def-hash @orchestre par la
                      # propriété "staff"
                      # 
  @data       = nil   # Les data telles que définies dans l'orchestre
  @ton        = nil   # La tonalité de la portée. C'est la tonalité du 
                      # morceau, par défaut, sauf pour les instruments
                      # transpositeur (p.e. sax en sib)
  @clef       = nil   # La clé générale pour l'instrument, parmi :
                      # G (sol), F (fa), U3 (ut 3e ligne), 
                      # U4 (ut 4e ligne)
  
  @staff      = nil   # Instance Staff pour la construction de la portée
                      # de l'instrument
  
  @motifs      = nil   # La liste Array des notes de l'instrument au 
                      # cours du morceau. Ce sont des instances de LINote
                      # contenant toutes les informations et notamment :
                      # l'octave, la durée
  
  @displayed = nil    # Détermine si l'instrument doit être affiché ou
                      # non (lorsqu'une option le retire)
                      
  def initialize data = nil
    @data       = data
    @motifs      = []
    @displayed  = true
    data.each do |prop, value|
      instance_variable_set("@#{prop}", value)
    end unless data.nil?
    @name = @staff
  end
  
  
  # => Retourne les mesures de l'instrument spécifiées par +params+
  # 
  # Cette méthode est une des méthodes principales de construction de la
  # partition. Même lorsqu'aucune mesure spéciale n'est demandée, elle
  # est appelée, avec les paramètres à nil
  # 
  # @note:  Si SCORE.bars est défini, et que c'est le premier instrument,
  #         on l'utilise pour ajouter les barres de mesure.
  # 
  def mesures first = nil, last = nil
    last ||= first
    # @TODO: produire ici une erreur si last est avant first ?
    
    jusqua_derniere = last == -1
    
    # Nombre de mesures attendues (if any)
    nombre_mesures_expected = 
      if first.nil? || last.nil? || jusqua_derniere
        nil
      else 
        last - first + 1
      end
    
    # Définition éventuelle des barres de mesure
    barres_mesures = SCORE.bars
    
    # Retourner toutes les notes s'il n'y a pas de filtre de mesure, et
    # aucune barre de mesures spéciales
    # puts "@motifs: #{@motifs.inspect}"
    # @motifs contient quelque chose comme : \relative c { a b c }
    return to_llp if first.nil? && last.nil? && barres_mesures.nil?
    first           = 1     if first.nil? 
    jusqua_derniere = true  if last.nil?

    duree_mesure = SCORE.duree_absolue_mesure
    
    position_courante       = 0
    index_mesure            = 1
    linotes_expected        = []
    last_duree_absolue      = 1.0   # Par défaut, une noire
    
    # Dans le cas où une liaison, une dynamique commencerait avant
    # la mesure désirée, on conserve sa trace pour l'ajouter en début
    # d'extrait.
    slure_run_before      = false
    legato_run_before     = false
    dyna_run_before       = false
    crescendo_run_before  = false
    slure_run_in          = false
    legato_run_in         = false
    dyna_run_in           = false
    
    
    # @FIXME:
    # Ici, en fonctionnant par explode, la notion de « Motif » est 
    # abandonnée, et donc toutes les informations les concernant. Par 
    # exemple, l'octave. Alors que :to_llp ci-dessus retourne un string
    # avec la marque relative d'octave, ici, on renvoie juste les notes.
    # Ce comportement ne va pas.
    # @SOLUTION: garder les motifs ici et boucler sur chacun d'eux en
    # gardant les mêmes traitement. À la fin d'une boucle sur un motif,
    # appeler to_llp pour en obtenir le code Lilypond.
    # Ou plutôt — mais ça ressemble à du bricolage —, pour pouvoir
    # conserver les traitements après la boucle, il faudrait juste
    # ajouter en string les marques relatives dans la liste des
    # LINote. Je vais faire ça pour le moment.
    
    
    # Variable qui sera mise à true quand la dernière note recherchée
    # sera atteinte.
    last_note_reached = false
    
    # = BOUCLE SUR CHAQUE MOTIF =
    
    @motifs.each do |motif|
      
      # Pour savoir si la marque relative a été posée pour le motif
      # courant
      relative_mark_posed = false
      
      # = BOUCLE SUR CHAQUE LINOTE DE CHAQUE MOTIF =
      
      explosion = motif.exploded
      unless explosion.empty?
        first_ln = explosion.first
        # Appliquer la duree et clef à la première LINote si nécessaire
        first_ln.set(:duration => motif.duration) if explosion.first.duration.nil?
        first_ln.set(:clef => motif.clef)         unless motif.clef.nil?
      end
      
      motif.exploded.each do |linote|
        # puts "\n= linote: #{linote.inspect}"

        # Tant qu'on n'a pas atteint la dernière mesure voulue,
        # on prend la linote si on a déjà passé la première mesure voulue
        if index_mesure >= first

          # --- AJOUT DE LA LINOTE --- #

          # Ajout de la marque relative
          unless relative_mark_posed
            linotes_expected << "#{motif.mark_relative} {"
            relative_mark_posed = true
          end
          
          # [N0001]
          linotes_expected << "\\clef \"#{linote.clef}\"" unless linote.clef.nil?

          linotes_expected << linote

          # [N0002]

        else
          # [N0003]
          if ! slure_run_before && linote.slure_start?
            slure_run_before = true
          elsif slure_run_before && linote.slure_end?
            slure_run_before = false
          end
          if ! legato_run_before && linote.legato_start?
            legato_run_before = true
          elsif legato_run_before && linote.legato_end?
            legato_run_before = false
          end
          if ! dyna_run_before && linote.dynamique_start?
            dyna_run_before = linote.dyna[:start] === true
            crescendo_run_before = linote.dyna[:crescendo] === true
          elsif dyna_run_before && linote.dynamique_end?
            dyna_run_before = false
          end
        end

        # 4 est mis en durée par défaut à la première note si aucune
        # durée n'est précisée
        unless linote.in_accord? && !linote.start_accord?
          duree_note = linote.duree_absolue( last_duree_absolue )
          position_courante += duree_note
          # Mémorisation de la dernière durée absolue
          last_duree_absolue = duree_note
        end

        # # = débug =
        # puts "\n=== in mesures ==="
        # puts "= linote: #{linote.inspect}"
        # puts "= linote.duree_absolue: #{linote.duree_absolue}"
        # puts "= Nouvelle position_courante: #{position_courante}"
        # puts "--------------------------------------"
        # # = /débug =

        if position_courante == duree_mesure
          # [N0004]
          unless linote.in_accord? && !linote.end_accord?
            index_mesure      += 1 
            unless barres_mesures.nil?
              if barres_mesures.has_key? index_mesure
                bar = "\\bar \"#{barres_mesures[index_mesure]}\""
                linotes_expected << bar
              end
            end
            position_courante =  0
            if jusqua_derniere == false && index_mesure > last
              last_note_reached = true
              break
            end
          end
        end

        # Démarrage d'un slure, un legato ou une dynamique
        if linote.slure_start?      then slure_run_in   = true
        elsif linote.slure_end?     then slure_run_in   = false end
        if linote.legato_start?     then legato_run_in  = true
        elsif linote.legato_end?    then legato_run_in  = false end
        if linote.dynamique_start?  then dyna_run_in    = true
        elsif linote.dynamique_end? then dyna_run_in    = false end

      end
      # / Fin de boucle sur les linotes du motif
      
      # Si la mark relative a été posée pour le motif, il faut fermer
      # l'accolade ouverte
      if relative_mark_posed
        linotes_expected << "}"
      end
      
      # Si on a atteint la dernière note voulue, il faut breaker
      break if last_note_reached
      
    end
    # / Fin de boucle sur tous les motifs

    # [N0005]
    # @FIXME : il faudrait fonctionner plus finement, car l'instrument
    # peut par exemple posséder seulement une noire ou autre dans la
    # mesure manquante.
    unless nombre_mesures_expected.nil?
      diff_nombre_mesures = nombre_mesures_expected - linotes_expected.count
      diff_nombre_mesures.times do |i|
        linotes_expected << ( mesure_vide ||= LINote::new("r1") )
      end
    end
    
    # Récupération de la première linote
    # @note 1 linotes_expected peut contenir des simples textes (comme
    #         par exemple des barres spéciales)
    # @note 2 Il se peut, dans l'absolu, qu'il n'y ait pas de first_ln
    first_ln = nil
    linotes_expected.each do |ln|
      next unless ln.class == LINote
      first_ln = ln
      break 
    end

    # [N0006]
    unless first_ln.nil?
      first_ln.send(
        first_ln.slure_end? ? 'erase_slure_end' : 'start_slure'
        ) if slure_run_before
      first_ln.send(
        first_ln.legato_end? ? 'erase_legato_end' : 'start_legato'
        ) if legato_run_before
      # @TODO: voir s'il n'est pas dangereux, pour les marques d'intensité,
      # d'éraser complètement la dynamique
      first_ln.send(
        first_ln.dynamique_end? ? 'erase_dynamique' :
        "start_#{crescendo_run_before ? '' : 'de'}crescendo"
      ) if dyna_run_before
    end
    
    # Récupération de la dernière linote
    # [N0007]
    last_ln = nil
    linotes_expected.reverse.each do |ln|
      next unless ln.class == LINote
      last_ln = ln
      break
    end

    # Suppression de démarrage de slure, legato ou dynamique sur 
    # dernière LINote
    # [N0008]
    unless last_ln.nil?
      last_ln.set(:legato => nil)   if last_ln.slure_start? || last_ln.legato_start?
      last_ln.set(:dyna => nil)     if last_ln.dynamique_start?
    
      last_ln.set(:duration => nil) if last_ln.duration == "~"
    
      # Ajout de fin de slure, de legato ou de dynamique ?
      if slure_run_in || legato_run_in || dyna_run_in
        # @note: l'ordre est important, ci-dessous
        last_ln.end_slure     if slure_run_in
        last_ln.end_legato    if legato_run_in
        if dyna_run_in
          # Mais ça peut être la note elle-même qui a généré ce départ de
          # dynamique.
          last_ln.end_dynamique 
        end
      end
    end
    linotes_expected = LINote::implode linotes_expected

    # # = débug =
    # puts "\n\n= LINotes obtenues pour l'instrument de classe #{self.class} :"
    # puts "= #{linotes_expected}"
    # # = / débug =

    linotes_expected
    
  end
  alias :measure  :mesures
  alias :mesure   :mesures
  alias :measures :mesures
  
  # =>  Retourne l'ensemble des notes de l'instrument, sous forme d'un
  #     Array d'objets LINote
  def explode
    ary_linotes = []
    @motifs.each do |motif|
      explosion = motif.exploded
      unless explosion.empty?
        first_ln = explosion.first
        # Appliquer la duree du motif à la première LINote si nécessaire
        first_ln.set(:duration => motif.duration) if explosion.first.duration.nil?
        first_ln.set(:clef => motif.clef) unless motif.clef.nil?
      end
      ary_linotes += explosion
    end
    ary_linotes
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
  # @param  aryormot  Array des instances LINotes à insérer dans les
  #                   notes de l'instrument.
  #                   OU un objet Motif
  # 
  # @param  params    Normalement, obsolète maintenant, car traité
  #                   directement dans les sous-méthodes add_as_<...>
  # 
  # @note:  C'est la méthode finale de la suite :
  #           add <something> (ci dessus)
  #           add_<suivant type something> (p.e. "add_as_motif")
  #           add_notes 
  # 
  # @note:  C'est dans cette méthode qu'on va gérer les delta pour faire
  #         le bon raccord octave avec les notes précédentes.
  #         OBSOLÈTE maintenant qu'on garde une liste de Motifs
  # 
  # @TODO:  le bug #15 pourra être supprimé, normalement, quand cette
  #         méthode sera efficiente
  # 
  def add_notes aryormot, params = nil
    
    return if aryormot.nil? || (aryormot.class == Array && aryormot.empty?)
    
    case aryormot.class.to_s
    when 'Motif' then ok = true
    when 'Array'
      aryormot = Motif.new LINote::implode aryormot
    else
      fatal_error(:bad_params_in_add_notes_instrument,
                  :instrument => @name,
									:params			=> aryormot)
    end
    
    @motifs ||= []
    @motifs << aryormot
    @motifs
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
    add_notes str.as_motif( params )
  end
  
  # => Ajoute la chose comme accord
  # @param  chord     Instance Chord de l'accord
  # @param  duree     Durée (lilypond) optionnelle
  # 
  # @todo: des vérifications de la validaté des paramètres
  def add_as_chord chord, params = nil
    add_notes chord.as_motif( params )
  end
  
  # => Ajoute la chose comme motif
  # @param  motif     Instance Motif du motif
  # @param  duree     Durée (lilypond) optionnelle
  # 
  def add_as_motif motif, params = nil
    unless params.nil?
      add_notes motif.set_params( params )
    else
      add_notes motif
    end
  end
  
  # =>  Définit la suite de notes de l'instrument au format lilypond
  # 
  # @principe: la méthode passe en revue toutes les LINotes de @motifs
  # et les ajoute.
  # 
  # @return   Le string fabriqué, prêt à être mis dans le score lilypond
  # 
  # @note     Ne commence pas par « \relative ... » (cf. ci-dessous)
  # 
  # @note     Ne pas mettre le résultat dans une propriété, car ça
  #           poserait problème pour les tests. Et normalement, cette
  #           méthode n'est appelée qu'une seule fois, pour créer la
  #           partition LilyPond
  # 
  def to_llp
    
    return "" if @motifs.empty? || @motifs.nil?
    
    # OBSOLÈTE: MAINTENANT, @motifs EST UNE LISTE DE MOTIFS
    # LINote::implode @motifs
    
    # Nouvelle formule, avec des motifs dans l'instrument
    # @TODO: peut-être, pour la clarté, faudra-t-il mettre des retours
    # chariot plutôt que des espaces ?
    llp = @motifs.collect { |motif| motif.to_s }.join(' ')
    
  end
  
  # -------------------------------------------------------------------
  #   Méthodes de construction du score Lilypond
  # -------------------------------------------------------------------

  # => Return le code lilypond pour l'instrument (hors accolades)
  #           OU false quand l'instrument ne doit pas être affiché
  # 
  # @param  params    
  #         Les paramètres optionnels pour l'affichage.
  #         :is_first     Mis à true si c'est le premier instrument de
  #                       l'orchestre. Permet de savoir s'il faut mettre
  #                       d'autres indications, comme par exemple les
  #                       numéros de mesures en cas d'un extrait
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
    return false unless @displayed
    @staff = Staff::new(
                        :clef         => @clef, 
                        :tempo        => SCORE.tempo, 
                        :base_tempo   => SCORE.base_tempo,
                        :octave_clef  => @octave_clef
                        )

    # @todo: ci-dessous, on pourra retirer le mark_relative, qui
    # ne sert à rien
    "\\new Staff {"                                   \
    << "\n\t#{mark_relative} {"                       \
    << "\n#{staff_header(params)}".gsub(/\n/, "\n\t")         \
    << "\n#{staff_content}".gsub(/\n/, "\n\t")[1..-1] \
    << "\n\t}\n}"
  end
  
  # => Return l'entête de la portée (clé, tempo, signature)
  # 
  # @note   Pour +params+, cf la méthode `to_lilypond' précédente.
  # 
  # @TODO: C'est dans ce header qu'on doit placer les informations
  # pour les numéros de mesure (en cas d'extrait par exemple)
  def staff_header params = nil
    key       = @staff.mark_key
    tempo     = @staff.mark_tempo
    mkey      = key.nil? ? "" : key
    mtempo    = tempo.nil? ? "" : tempo
    mshowmes  = Instrument::code_show_bar_numbers(SCORE::from_mesure)
    
    # Code retourné : 
    @staff.mark_clef    << "\n"  \
    << @staff.mark_time << "\n"  \
    << mkey << mtempo << mshowmes
  end
  
  # => Return le contenu des notes de l'instrument
  # 
  # @note: si un filtre des mesures est appliqué, on l'utilise
  # 
  def staff_content
    mesures SCORE::from_mesure, SCORE::to_mesure
  end
  
  # => Return la marque « \relative c... »
  # 
  def mark_relative
    Score::mark_relative( octave )
  end
  
  # => Return l'octave de départ pour l'instrument
  # 
  # C'est soit l'octave de la première note, soit l'octave par défaut
  # de l'instrument
  # 
  # @note:  Par défaut, l'octave est 4
  # 
  def octave
    (@motifs.empty? ? @octave_defaut : @motifs.first.octave) || 4
  end
  
end