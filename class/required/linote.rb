# 
# Class LINote
# 
# Permet toutes les opérations sur les notes
# 
require 'String'
require 'note'

class LINote < NoteClass
  
  # -------------------------------------------------------------------
  #   Constantes
  # -------------------------------------------------------------------

  unless defined? NOTE_STR_TO_INT
    
    SUITE_DIESES = ['f', 'c', 'g', 'd', 'a', 'e', 'b']
    SUITE_BEMOLS = SUITE_DIESES.reverse
    
    
    ALTERS_PER_TUNE = {
      'C'   => { :nombre => 0, :suite => nil, :add => nil},
      'G'   => { :nombre => 1, :suite => SUITE_DIESES,  :add => 'is' },
      'D'   => { :nombre => 2, :suite => SUITE_DIESES,  :add => 'is' },
      'A'   => { :nombre => 3, :suite => SUITE_DIESES,  :add => 'is' },
      'E'   => { :nombre => 4, :suite => SUITE_DIESES,  :add => 'is' },
      'B'   => { :nombre => 5, :suite => SUITE_DIESES,  :add => 'is' },
      'F#'  => { :nombre => 6, :suite => SUITE_DIESES,  :add => 'is' },
      'C#'  => { :nombre => 7, :suite => SUITE_DIESES,  :add => 'is' },
      'F'   => { :nombre => 1, :suite => SUITE_BEMOLS,  :add => 'es' },
      'Bb'  => { :nombre => 2, :suite => SUITE_BEMOLS,  :add => 'es' },
      'Eb'  => { :nombre => 3, :suite => SUITE_BEMOLS,  :add => 'es' },
      'Ab'  => { :nombre => 4, :suite => SUITE_BEMOLS,  :add => 'es' },
      'Db'  => { :nombre => 5, :suite => SUITE_BEMOLS,  :add => 'es' },
      'Gb'  => { :nombre => 6, :suite => SUITE_BEMOLS,  :add => 'es' },
      'Cb'  => { :nombre => 7, :suite => SUITE_BEMOLS,  :add => 'es' }
    }
    # Liste transformant les notes bémols ou complexe en leur valeur
    # simple dièse.
    # Cette liste permettra de trouver l'index absolu de la note dans la
    # gamme chromatique (pour recherche d'intervalle par exemple)
    # 
    # @note : les notes sans transformations ont été ajoutées pour
    #         pouvoir utiliser LISTE_ALT_TO_ALT_SIMPLE[note] sans tester
    #         si la clé existe.
    LISTE_ALT_TO_ALT_SIMPLE = {
      'c'=>"c", 'ces'=>"b", 'ceses'=>"ais", 'cis'=>"cis", 'cisis'=>"d",
      'd'=>"d", 'des'=>"cis", 'deses'=>"c", 'dis'=>"dis", 'disis'=>"e",
      'e'=>"e", 'ees'=>"dis", 'eeses'=>"d", 'eis'=>'f',   'eisis'=>"fis",
      'f'=>"f", 'fes'=>"e", 'feses'=>"dis", 'fis'=>"fis", 'fisis'=>"g",
      'g'=>"g", 'ges'=>"fis", 'geses'=>"f", 'gis'=>"gis", 'gisis'=>"a",
      'a'=>"a", 'aes'=>"gis", 'aeses'=>"g", 'ais'=>"ais", 'aisis'=>"b",
      'b'=>"b", 'bes'=>"ais", 'beses'=>"a", 'bis'=>"c",   'bisis'=>'cis'
    }
    
    # La gamme chromatique (seulement en dièses)
    # @note: c'est cette gamme qui doit être utilisée conjointement à
    # LISTE_ALT_TO_ALT_SIMPLE pour trouver l'intervalle entre deux notes
    GAMME_CHROMATIQUE = 
      ["c", "cis", "d", "dis", "e", "f", "fis", "g", "gis", "a", "ais", "b"]
    # La gamme chromatique (seulement bémols)
    GAMME_CHROMATIQUE_BEMOLS = 
      ["c", "des", "d", "ees", "e", "f", "ges", "g", "aes", "a", "bes", "b"]
    # La gamme diatonique
    GAMME_DIATONIQUE = ["c", "d", "e", "f", "g", "a", "b"]
    
    # Table de correspondance entre la note en string ("g") et la valeur
    # entière
    NOTE_STR_TO_INT = {
      "bis"   => 0,   "bisis" => 1, "ces" => 11, "ceses" => 10,
      # Pour tenir compte du changement d'octave :
      # Mais ça fait échouer les jointures. Plutôt, on traite le cas
      # du changement d'octave dans LINote#abs
      # "bis"   => 12,  "bisis" => 13, "ces" => -1, "ceses" => -2,
      "deses" => 0,   "c"   => 0,
      "cis"   => 1,   "bisis" => 1,   "des" => 1, 
      "eeses" => 2,   "cisis" => 2,   "d"   => 2,
      "dis"   => 3,   "feses" => 3,   "ees" => 3,
      "disis" => 4,   "fes"   => 4,   "e"   => 4,
      "eis"   => 5,   "geses" => 5,   "f"   => 5,
      "ges"   => 6,   "eisis" => 6,   "fis" => 6,
      "fisis" => 7,   "aeses" => 7,   "g"   => 7, 
      "gis"   => 8,                   "aes" => 8,
      "gisis" => 9,   "beses" => 9,   "a"   => 9,
      "ais"   => 10,                  "bes" => 10,
      "aisis" => 11,                  "b"   => 11
    }
    NOTE_INT_TO_STR = {
      0   => {:natural => "c",    :tonal => {'is' => 'bis', 'es' => 'deses'} },
      1   => {:natural => "cis",  :tonal => {'is' => 'cis', 'es' => 'des'} },
      2   => {:natural => "d"},   :tonal => nil,
      3   => {:natural => "ees",  :tonal => {'is' => 'dis', 'es' => 'ees'}},
      4   => {:natural => "e",    :tonal => nil},
      5   => {:natural => "f",    :tonal => nil},
      6   => {:natural => "fis",  :tonal => {'is' => 'fis', 'es' => "ges"}},
      7   => {:natural => "g",    :tonal => nil},
      8   => {:natural => "aes",  :tonal => {'is' => 'gis', 'es' => 'aes'}},
      9   => {:natural => "a",    :tonal => nil},
      10  => {:natural => "bes",  :tonal => {'is' => 'ais', 'es' => 'bes'}},
      11  => {:natural => "b",    :tonal => nil}
    }
    
    d = "dieses/N"
    b = "bemols/N"
    tonalites = <<-HDEF
        ton   fr               #{d}  #{b}   llp
      -------------------------------------------------------------------
        C     Do_majeur         0     0     c
        G     Sol_majeur        1     0     g
        D     Ré_majeur         2     0     d
        A     La_majeur         3     0     a
        E     Mi_majeur         4     0     e
        B     Si_majeur         5     0     b
        F#    Fa_dièse_majeur   6     0     fis
        C#    Do_dièse_majeur   7     0     cis
        F     Fa_majeur         0     1     f
        Bb    Si_bémol_majeur   0     2     bes
        Eb    Mi_bémol_majeur   0     3     ees
        Ab    La_bémol_majeur   0     4     aes
        Db    Ré_bémol_majeur   0     5     des
        Gb    Sol_bémol_majeur  0     6     ges
        Cb    Do_bémol_majeur   0     7     cb
      -------------------------------------------------------------------
    HDEF
    TONALITES = tonalites.to_hash(to_sym=false)
    
    # Expression régulière pour repérer les notes dans un motif
    # 
    # @todo: il faudra l'affiner au cours du temps
    # Cf le motif REG_NOTE_COMPLEXE pour quelque chose de plus complet
    REG_NOTE = %r{([a-gr](?:(?:es|is){1,2})?)}
    # REG_NOTE = %r{<?[a-gr](?:(?:es|is){1,2})?>?}
    REG_NOTE_WITH_DUREE = %r{([a-gr](?:eses|isis|es|is)?)([0-9.~]+)?}
    
    # Expression régulière pour repérer un accord
    # 
    REG_CHORD = %r{(<[a-gr](?:[^>]+)>)}
    REG_CHORD_WITH_DUREE = %r{(<[a-gr](?:[^>]+)>)([0-9.~]*)?}
    
    # Altérations normales vers altérations lilypond
    ALTERATIONS = { '#' => 'is', '##' => 'isis', 'b' => 'es', 
                    'bb' => 'eses'}
    
    # Expression régulière pour transformer les italienne en 
    # anglosaxonnes
    # @note: c'est la constante Note::ITAL_TO_ANGLO qui permettra
    # d'obtenir la note anglosaxonne.
    REG_ITAL_TO_LLP = %r{\b(ut|do|re|ré|mi|fa|sol|la|si)}
    
    # Le motif de crescendo/decrescendo :
    # commence toujours par : "\\"
    REG_DYNAMIQUE = /\\(?:>|<|\!|f+|p+)/

    BIT_START_SLURE   = 1
    BIT_START_LEGATO  = 2
    BIT_END_SLURE     = 4
    BIT_END_LEGATO    = 8
    
    # Expressions régulières pour capter les liaisons (if any)
    REG_START_LEGATO  = /\\\(/
    REG_END_LEGATO    = /\\\)/
    REG_START_SLURE   = /\(/
    REG_END_SLURE     = /\)/
    
    # Expressions régulières pour capter les crescendo/decrescendo (if any)
    REG_START_CRESCENDO   = /\\</
    REG_START_DECRESCENDO = /\\>/
    REG_END_CRESCENDO     = /\\\!/

    # Expression régulière permettant d'exploder les notes
    # de la suite de notes LilyPond fournie
    REG_NOTE_COMPLEXE = %r{
      (<)?                    # Texte préliminaire éventuel
      ([a-gr])                # La note ou le silence
      (isis|eses|is|es)?      # Altération éventuelle
      ([',]+)?                # Octaves éventuels
      ([0-9.~]{1,6})?         # Durée éventuelle
      (                       # Notes de jeu
        -                     # ------------
        -?
        [.^_]*                # Les signes de jeu qu’on peut trouver ---
      )?
      (                       # Doigté à appliquer
        -                     # -------------------
        [0-9]                 # Optionnel
      )?
      (
        >?                    # post - ce qui peut se trouver après la note
        [\(\)\[\]]{0,3}       # comme la marque de fin d’accord, la marque
        (?:\\\)|\\\()?        # de fin de slur, la marque de détachement
        [\(\)\[\]]{0,3}       # des beams — crochets – etc.
      )?
      ([0-9.]{1,4})?          # Durée post éventuelle - après accord p.e.
      (#{REG_DYNAMIQUE})?     # Marque de crescendo ou decrescendo
      }x
      # --- @todo: il faudra ajouter les marques de doigté
  end # / si constantes déjà définies (tests)
  
  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------
  @@duration = nil
  
  # =>  Définit et retourne les altérations des notes dans la tonalité
  #     +key+ fournie
  # 
  # @return:  Un hash avec en clé la note sans altération et en 
  #           valeur la note avec son altération si elle est
  #           nécessaire dans la tonalité voulue.
  # 
  # @note:    On peut travailler avec plusieurs tonalités puisque 
  #           chaque tonalité utilisée au cours du programme est mise 
  #           dans un hash avec en clé la-dite tonalité
  # 
  def self.alterations_notes_in_key key
    key ||= SCORE::key || "C"
    key = key.capitalize
    @@alteration_notes_per_key ||= {}
    @@alteration_notes_per_key[key] ||= lambda {
      data_key = ALTERS_PER_TUNE[key]
      nombre_alters = data_key[:nombre]
      suite_alters  = data_key[:suite]
      alter_to_add  = data_key[:add]
      hash_alters =
      {'c'=>'c', 'd'=>'d', 'e'=>'e', 'f'=>'f', 'g'=>'g', 'a'=>'a', 'b'=>'b'}
      if nombre_alters > 0
        nombre_alters.times do |i|
          note = suite_alters[i]
          hash_alters[note] << alter_to_add
        end
      end
      hash_alters
    }.call
  end
  
  # =>  Return un hash de données paire clé-value où la clé est une note
  #     et la valeur son altération SEULE dans la tonalité donnée.
  #     Pour obtenir la note avec son altération toute prête, utiliser
  #     plutôt la méthode précédente.
  def self.alteration_for_notes_in_key
    key ||= SCORE::key || "C"
    key = key.capitalize
    @@alteration_for_notes_in_key ||= {}
    @@alteration_for_notes_in_key[key] ||= lambda {
      data_key = ALTERS_PER_TUNE[key]
      nombre_alters = data_key[:nombre]
      suite_alters  = data_key[:suite]
      alter_to_add  = data_key[:add]
      hash_alters =
      {'c'=>'', 'd'=>'', 'e'=>'', 'f'=>'', 'g'=>'', 'a'=>'', 'b'=>''}
      if nombre_alters > 0
        nombre_alters.times do |i|
          note = suite_alters[i]
          hash_alters[note] << alter_to_add
        end
      end
      hash_alters
    }.call
  end
  
  # => Return une LINote d'après le string LilyPond +note_llp+
  # 
  # @param  note_llp    Un string de note LilyPond, qui peut être
  #                     complexe (p.e. « cisis,,8.-^( » ), mais en tout
  #                     cas une seule.
  # 
  # @return Une Linote contenant toutes les données
  # 
  # @note:  C'est une des méthodes les plus importantes du programme,
  #         puisque les LINotes sont utilisées intensivement comme
  #         atome de base à beaucoup d'opérations.
  # 
  def self.llp_to_linote note_llp
    # String requis
    fatal_error(:bad_type_for_args, 
      :method => "LINote::llp_to_linote",
      :good   => "String", 
      :bad    => note_llp.class.to_s) unless note_llp.class == String
    
    note_llp = note_llp.strip
    note_llp.scan(/^#{REG_NOTE_COMPLEXE}$/){
      tout, pre, note, alter, mark_delta, duree, jeu, finger, post, 
      duree_post, mark_dyna = 
        [$&, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10]
      
      # # = débug =
      # puts "\n=== LINote::llp_to_linote(note_llp:'#{note_llp}')"
      # puts "= mark_dyna: '#{mark_dyna}'"
      # puts "------------------------------------"
      # # = / débug =
      
      # Étude du jeu et du doigté
      # -------------------------
      # (pour retirer le tiret qui les précède)
      jeu     = jeu[1..-1]    unless jeu.to_s.blank?
      finger  = finger[1..-1] unless finger.to_s.blank?

      # Étude de la dynamique
      unless mark_dyna.to_s.blank?
        dyna = extract_dynamique_values mark_dyna
        # puts "\n dyna retourné: #{dyna.inspect}"
      end
      
      # Étude de la valeur :post
      # ------------------------
      # (qui peut contenir les marques de 
      #  dynamique et de liaison — legato et slure, transformées en
      #  propriétés @legato et @dyna)
      unless post.nil? || post.blank?
        legato, post = extract_post_values post
      else
        legato = nil
      end
      
      # Composition de la linote
      # ------------------------
      return LINote::new(
        :note => note, :duration => duree, :duree_post => duree_post, 
        :delta => delta_from_markdelta(mark_delta),
        :pre  => pre,  :alter => alter, :jeu => jeu, :post => post.to_s,
        :legato => legato, :dyna => dyna,
        :finger => finger
        )
    }
    # Si on passe ici, c'est que le motif n'a pas été trouvé, que
    # +note_llp+ n'était donc pas au bon format
    fatal_error(:not_note_llp, :note => note_llp)
  end
  
  # =>  Extrait de +mark+ les indications sur la dynamique
  # 
  # @param  mark   Une indication dynamique, comme '\>', '\!', etc.
  # 
  # @return le hash dynamique à enregistrer dans la LINote
  # 
  def self.extract_dynamique_values mark    
    dyna = nil
    rest = mark.sub(REG_START_CRESCENDO, '')
    if rest != mark
      dyna = {:start => true, :crescendo => true}; mark = rest
    else
      rest = mark.sub(REG_END_CRESCENDO, '')
      unless rest == mark
        dyna = {:end => true }; mark = rest
      else
        rest = mark.sub(REG_START_DECRESCENDO, '')
        unless mark == rest
          dyna = {:start => true, :crescendo => false}; mark = rest
        end
      end
    end
    dyna
  end
  # =>  Extrait de la valeur 'post' de la note analysée les liaisons et
  #     la dynamique éventuelle et renvoie :
  #     [value @legato, value @dyna, value post restante]
  def self.extract_post_values post
    return [nil, nil, post] if post.nil? || post.blank?
 
    # puts "\n--> LINote::extract_post_values(post:'#{post}')"
    
    # Une liaison ?
    legato = 0
    rest = post.sub(REG_START_LEGATO, '')
    if post != rest # => il y a une marque de début de legato
      legato = BIT_START_LEGATO; post = rest
    end
    rest = post.sub(REG_START_SLURE, '')
    if post != rest # => il y a une marque de début de slure
      legato += BIT_START_SLURE; post = rest
    end
    rest = post.sub(REG_END_LEGATO, '')
      # @note: il faut le mettre avant le test suivant, sinon, '('
      # serait repéré avant '\('
    if rest != post # => il y a une marque de fin de legato
      legato = BIT_END_LEGATO ; post = rest
      # Noter que s'il y a une erreur de fin en même temps qu'un
      # début, elle sera effacé ici (mais pas ci-dessous)
    end
    rest = post.sub(REG_END_SLURE, '')
    if post != rest # => il y a une marque de fin de slure
      legato += BIT_END_SLURE; post = rest
    end
    legato = nil if legato == 0
    
    # puts "= post: #{post}"
    # puts "= rest: #{rest}"
    # puts "---------------------------"

    # La liste renvoyée
    [legato, rest]
  end
  
  # => Return les données notes du motif +str+ (motif LilyPond)
  # ------------------------------------------------------------
  # @param  some  Un string contenant les notes à analyser
  #               OU une instance de Motif
  # 
  # @return Une liste d'instance LINote : cf. l'instance pour le 
  #         détail des propriétés
  # 
  def self.explode some, current_octave = nil
    # puts "\n\n--> explode '#{some}' avec some de classe #{some.class} / octave : #{current_octave}"
    data = []
    # puts "\n\n-->LINote::explode"
    # puts "= Class de some: #{some.class}"
    ary_str = case some.class.to_s
              when "String" then some.split(' ')
              when "Motif"  then 
                current_octave = some.octave
                # Le motif a-t-il déjà été explodé ?
                return some.exploded unless instance_variable_get("@exploded").nil?
                some.simple_notes.split(' ')
              else 
                fatal_error(
                  :bad_type_for_args, :method => "LINote::explode",
                  :good => "String ou Motif", :bad => some.class.to_s
                  )
              end
    
    inote           = 0
    in_accord       = false
    current_octave  ||= 4
    accord_start    = nil # indice de la première note de l'accord trouvé

    ary_str.each do |membre|
      ln = llp_to_linote( membre )
      # puts "\n= «#{membre}» après llp_to_linote: #{ln.inspect}"
      if ln.start_accord?
        # @note: il ne faut pas calculer `accord_start' ici, car dans
        # le cas où deux accords se suivrait, la première note du 
        # second ne pourrait pas prendre en référence la première du
        # précédent pour le calcul de son octave
        # DONC : `accord_start  = 0 + inote' est calculé en bout de
        # boucle.
        in_accord = true
        ln.set :in_accord => true
      elsif in_accord 
        ln.set :in_accord => true
        if ln.end_accord?
          # Dernière note d'un accord
          # => Il faut prendre sa durée (if any) et la mettre à toutes
          # les notes de l'accord
          duree = ln.get( :duree_post )
          ln.set( :duree_chord => duree )
          unless duree.to_s.blank?
            (accord_start..(inote-1)).each do |i|
              data[i].set :duree_chord => duree
              # Note: on ne peut pas modifier la note courante par ce
              # biais puisqu'elle n'est pas encore dans data
            end
          end
          in_accord = false
        end
      end
      
      # Réglage de l'octave
      # --------------------
      # @note:  `current_octave' contient la valeur courante de l'octave
      #         en tenant compte des accords, sachant qu'en Lilypond,
      #         c'est seulement la première note de l'accord qui décide
      #         de la hauteur de référence de la note suivante.
      #         En conséquence, l'octave courante ne change pas quand
      #         on est à l'intérieur d'un accord et que ce n'est pas la
      #         première note de l'accord.
      #         Dans tous les autres cas, l'octave courante change si
      #         on franchit un do.
      # 
      octave_for_ln = nil
      
      if inote > 0
        prev_ln = data[ inote - 1 ]
        # La linote de référence (pour comparaison d'octave) est 
        # soit la note précédente soit la première note de l'accord
        # précédent (if any)
        # puts "\n\n= Étude octave de linote[#{inote}] #{ln.inspect}"
        # puts "= accord_start: #{accord_start}" if prev_ln.end_accord?
        ln_ref  = prev_ln.end_accord? ? data[accord_start] : prev_ln
        if ln.in_accord?
          # --- Intérieur d'un accord ---
          if ln.start_accord?
            # puts "\n\nNatural octave after appelé avec ln_ref:#{ln_ref.inspect}"
            current_octave  = ln.natural_octave_after( ln_ref )
            # puts "current_octave mis à : #{current_octave} pour #{ln.inspect}"
          else
            # À l'intérieur d'un accord (sauf première note), on définit
            # l'octave pour la linote, mais on ne touche pas à l'octave
            # courante.
            # puts "\n\nNatural octave after appelé avec prev_ln:#{prev_ln.inspect}"
            octave_for_ln = ln.natural_octave_after( prev_ln )
            # puts "octave_for_ln mis à #{octave_for_ln}"
          end
        else
          # --- Extérieur d'un accord ---
          # 
          # => Modification de l'octave si nécessaire
          # puts "\n\nNatural octave after (extérieur accord) appelé avec ln_ref:#{ln_ref.inspect}"
          current_octave = ln.natural_octave_after ln_ref
          # puts "current_octave mis à : #{current_octave}"
        end
      else
        # --- Toute première note ---
        # L'octave courante est calculée d'après son delta, lequel delta
        # doit être toujours mis à zéro
        current_octave = current_octave + ln.delta
        ln.set :delta => 0
        # puts "\ncurrent_octave mis à #{current_octave} par la toute première note"
      end
      ln.set :octave      => (octave_for_ln ||= current_octave) 
      ln.set :real_octave => octave_for_ln + ln.delta
      
      # Ajout à la liste des linotes
      # -----------------------------
      data << ln
      accord_start = (0 + inote) if ln.start_accord?
      inote += 1
    end
    data
  end
  
  # =>  Reconstitue le string LilyPond à partir de la liste des
  #     Linotes envoyées
  def self.implode liste_linotes
    liste_linotes.collect { |linote| linote.to_llp }.join(' ')
  end
  
  # =>  Mémorise la durée qui devra être appliquée plus tard (à la fin
  #     de l'accord if any) au cours de l'implode d'une liste de 
  #     LINotes
  def self.duration_pour_implode duree
    if duree === true
      return @@duration || ""
    else
      @@duration = duree
    end
  end
  
  # =>  Return +notes+ avec '#' et 'b' pour dièse et bémol en 'is' et
  #     'es' et les notes italiennes remplacées par leur valeur
  #     anglosaxonne.
  # @param  notes   Un string de note
  # 
  def self.to_llp notes
    is_array = notes.class == Array
    notes = notes.join(' • ') if is_array
    # Transformation des italiennes
    notes = notes.gsub(REG_ITAL_TO_LLP){
      Note::ITAL_TO_ANGLO[$1]
    }
    # Transformation des dièses et bémols
    notes = notes.gsub(/\b([a-g])([#b]{1,2})/){
      "#{$1}#{LINote::ALTERATIONS[$2]}"
    }
    notes = notes.split(' • ') if is_array
    return notes
  end
  
  # => Vérifie que +some+ soit bien un motif dans la méthode +method+
  # 
  # @return true si c'est un motif, lève une erreur fatale ou renvoie
  #         false si +fatal+ est false.
  # 
  def self.should_be_motif_in method, some, fatal = true
    return true if some.class == Motif
    return false unless fatal
    fatal_error(:bad_type_for_args, :good => "Motif", 
      :bad => some.class, :method => method)
  end
  
  # =>  Join la suite de note +motif1+ à la suite +motif2+
  #     en retournant un string prenant en compte les octaves (delta)
  # 
  # @param  motif1      Instance de Motif.
  # @param  motif2      Deuxième instance de Motif, à joindre à la 
  #                     première
  # 
  # @return Le String des notes jointes.
  #         Par exemple : 
  #           - le motif "c e g" octave 3 
  #           - join au motif "c g e c" octave 3 produira
  #           => "c e g c, g e c" avec la virgule qui ramène à l'octave
  #           3 alors que la simple jointure "c e g c g e c" ferait que
  #           le second do serait un do 4, contrairement à ce qui est
  #           attendu.
  # 
  def self.join motif1, motif2

    # Il faut impérativement deux motifs
    should_be_motif_in 'LINote::join', motif1
    should_be_motif_in 'LINote::join', motif2
    			
    # On prend la première et la dernière note
    # -----------------------------------------
    # @note: dans le cas où le motif ne contiendrait que des silences,
    # la linote renvoyée sera nulle. Dans ce cas, on doit quand même
    # prendre son octave.
    # 
    ln_avant = motif1.last_note(  strict = true )
    ln_apres = motif2.first_note( strict = true )
    
    if ln_avant.nil? || ln_apres.nil?
      # Un des deux motifs n'est composé que de silences
      # Si c'est le deuxième, il n'y a rien à faire. En revanche, si
      # c'est le premier, il faut peut-être mettre un delta d'octave
      # sur le second motif
      if ln_avant.nil?
        ln_apres.set :delta => motif2.octave - motif1.octave
      end
    else
      # Les deux motifs ont au moins une note
      # puts "\n\n= ln_avant : #{ln_avant.inspect}"
      # puts "= ln_apres (AVANT as_next_of): #{ln_apres}"
      ln_apres.as_next_of ln_avant
      # puts "= ln_apres (APRES as_next_of): #{ln_apres}"
      # puts "= motif2 AVANT set_first_note: #{motif2.inspect}"
      motif2.set_first_note( ln_apres, strict = true )
      # puts "= motif2 APRÈS set_first_note: #{motif2.inspect}"
    end
    
    # puts "\nmotif1.to_llp: #{motif1.to_llp}"
    # puts "\nmotif2: #{motif2.inspect}" # ICI, le motif est déjà mauvais (2e note avec duration à 8)
    # puts "\nmotif2.to_llp: #{motif2.to_llp}"
    # puts "---"
    # On compose les notes du motif
    "#{motif1.to_llp} #{motif2.to_llp}"
    
  end

  # =>  Pose une marque de début (donc après la première note) et de fin
  #     (donc après la dernière note) sur les +notes+
  # 
  # @param  notes     SOIT un String des notes, SOIT une liste Array de
  #                   LINotes
  # @param  markin    La marque à mettre sur la 1ere note (p.e. « \( »)
  # @param  markout   La marque à mettre sur la dern note (p.e. « \) »)
  # 
  # @return   La liste des LINotes modifiées
  # 
  # @note:  ne peut déposer la marque +markin+ ou +markout+ QUE sur des
  #         notes, pas des silences
  # 
  def self.post_first_and_last_note notes, markin, markout
    # puts "\n--> post_first_and_last_note"
    # puts "= markin: '#{markin}'"
    # puts "= markout: '#{markout}'"
    res = post_first_note(notes, markin)  unless markin.nil?
    res = post_last_note(res, markout)    unless markout.nil?
    res
  end

  # =>  Ajoute +sig+ au @pre de la première note de +some+
  # 
  # @param  some    Un string (suite de notes) ou Array de LINote
  # @param  sig     Le signe à ajouter (p.e. '<')
  # 
  # @return La liste de linotes obtenues (juste pour convénience puisque
  #         la modification se fait par référence)
  # 
  # @note:  Le signe ne peut être ajouté à un silence.
  # @note:  on ne retourne pas un string, car cette méthode s'insert
  #         le plus souvent dans une suite de traitements où on a besoin
  #         de la liste des LINotes.
  # @note:  Le signe est ajouté AVANT le signe qui peut déjà se trouver 
  #         dans la linote
  # 
  def self.pre_first_note some, sig
    some = as_array_of_linotes(some)
    some.each do |ln|
      unless ln.rest?
        ln.set(:pre => sig) and break if ln.pre.nil?
        # Si @pre contient déjà le signe, on ne fait rien
        deja_le_sig = 
              (ln.pre[0..sig.length - 1] == sig) \
          ||  (ln.pre[-sig.length..-1]   == sig)
        ln.set(:pre => "#{sig}#{ln.pre}") unless deja_le_sig
        break 
      end
    end
    some
  end

  # =>  Ajoute +sig+ au @post de la première note de +some+
  # 
  # @param  some    Un string (suite de notes) ou Array de LINote
  # @param  sig     Le signe à ajouter (p.e. '\(')
  # 
  # @return La liste de linotes obtenues (juste pour convénience)
  # 
  # @note:  on ne retourne pas un string, car cette méthode s'insert
  #         le plus souvent dans une suite de traitements où on a besoin
  #         de la liste des LINotes.
  # 
  def self.post_first_note some, sig
    some = as_array_of_linotes(some)
    some.each do |ln|
      unless ln.rest?
        case sig
        when '('  then ln.start_slure
        when ')'  then ln.end_slure
        when '\(' then ln.start_legato
        when '\)' then ln.end_legato
        when '\!' then ln.end_crescendo
        when '\<' then ln.start_crescendo
        when '\>' then ln.start_decrescendo
        else
          unless sig.match(/^ \\[pfm]/).nil?
            # Une marque post pour une dynamique
            ln.end_intensite sig
          else
            fatal_error(:bad_value_post_for_linote, 
                      :linote => self, :bad => "`#{sig}'")
          end
        end
        break
      end
    end
    some
  end
  # (même chose que la précédente, mais pour poser la marque sur la
  # dernière note — pas silence)
  def self.post_last_note some, sig
    some = as_array_of_linotes(some)
    post_first_note(some.reverse, sig)
    some
  end
  
  # =>  Return une liste de linotes de +some+ (qui peut déjà en être 
  #     une)
  # 
  # @param  some    Soit un String de notes LilyPond, soit une liste de
  #                 LINotes
  # @return Une liste des LINotes
  #         Ou lève une erreur fatale en cas de mauvais arguments
  # 
  def self.as_array_of_linotes some, method = nil
    return some if some.class == Array
    ary = case some.class.to_s
          when "String" then some.as_motif.exploded                           
          when "Array"  then some                                             
          end                                                                     
    return ary if ary.class == Array && ary.first.class == LINote
    fatal_error(:bad_type_for_args,
                :method => caller[0][/`([^']*)'/, 1],
                :good   => "Array de LINotes ou String",
                :bad    => ary.class.to_s)
  end

  # =>  Hausse toutes les LINotes de +ary_linotes+ du nombre de +degres+
  #     voulus dans la tonalité courante
  # 
  # @param  ary_linotes     Liste (Array) des LINotes
  # @param  degres          Nombre de degrés voulus
  # 
  # @return   Liste de LINotes ré-haussées
  # @note     Ce sont des clones des LINotes initiales, qui ne sont donc
  #           pas modifiées.
  def self.up ary_linotes, degres
    ary_linotes.collect{ |ln| ln.up degres }
  end
  # =>  Hausse toutes les LINotes de +ary_linotes+ du nombre de +degres+
  #     voulus dans la tonalité courante
  # @note:  Cf. self.up pour le détail
  def self.down ary_linotes, degres
    up ary_linotes, -degres
  end

  # =>  Return la valeur string de la note en fonction du +context+
  #     soumis.
  #     CETTE MÉTHODE DOIT DEVENIR OBSOLÈTE (ELLE N'EST PAS EFFICIENTE)
  # @param note_int La note, exprimée en entier.
  # @param context  Hash qui doit définir au moins la clé :tonalite
  #                 indiquant la tonalité dans laquelle se trouve la
  #                 note.
  def self.note_str_in_context note_int, context = nil
    note_int = note_int % 12
    data_note     = NOTE_INT_TO_STR[ note_int ]
    return data_note[:natural] if 
      context.nil? || 
      !context.has_key?( :tonalite ) ||
      context[:tonalite].nil? ||
      data_note[:tonal].nil?
    data_tonalite = TONALITES[context[:tonalite]]
    sens          = data_tonalite['bemols'] == 0 ? 'is' : 'es'
    note = data_note[:tonal][sens]
    # Si c'est une double-dièse ou double-bémol, on prend plutôt
    # la note naturelle, dans ce contexte
    note = data_note[:natural] if note.length > 3
    return note
  end
  
  # =>  Return le DELTA d'octave exprimé en nombre d'après une marque 
  #     lilypond (en apostrophes et/ou virgules)
  # 
  # ATTENTION : LA VALEUR RETOURNÉE NE CORRESPOND PAS À L'OCTAVE ABSOLU
  # DE LA NOTE, PUISQUE LES APOSTROPHES ET VIRGULES S'INTERPRÊTENT PAR
  # RAPPORT À LA HAUTEUR DE LA NOTE PRÉCÉDENTE. C'EST UN DELTA D'OCTAVE
  # 
  def self.delta_from_markdelta oct_llp
    return 0 if     oct_llp.nil?    \
                ||  oct_llp.blank?  \
                ||  oct_llp.scan(/[',]/) == []
    octave = 0
    oct_llp.split('').each do |lettre|
      case lettre
      when "'" then octave += 1
      when "," then octave -= 1
      end
    end
    octave
  end
  
  # =>  Retourne la marque LilyPond delta pour le delta +delta+
  #     Par exemple, pour 3, retourne « ''' »
  def self.mark_delta delta
    return "" if delta == 0
    mk = delta > 0 ? "'" : ","
    mk.fois(delta.abs)
  end
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :note, :duration, :alter, :delta, :pre, :post,
              :duree_post, :duree_chord, :dyna, :legato
  
  @note       = nil   # La note simple (SEULEMENT a-g / r)
  @alter      = nil   # Altération de la note (p.e. "eses" ou "is")
  @pre        = nil   # Ce qui précède la note (p.e. '<')
  @post       = nil   # Ce qui suit la note (p.e. '>' ou ')')
  @duration   = nil   # La durée de la note (p.e. "4.")
  @duree_post = nil   # La "post-durée", p.e. après un accord, si la
                      # dernière note : "<.... a>8.", "8." est la 
                      # duree_post (@note: ça sert pour :explode et
                      # :implode)
  @in_accord  = nil   # Dans l'explosion, cette propriété est mise à 
                      # true si on se trouve dans un accord
  @duree_chord=nil # Lors de l'explosion (explode), si la méthode
                      # rencontre un accord, elle affecte à toutes les
                      # notes la durée trouvée pour la dernière.
                      # Cette propriété n'existe donc que pour les
                      # notes des accords
  @mark_delta = nil   # Le delta d'octave, au format LLP (p.e. « '' »)
                      # Calculée d'après @delta par la méthode éponyme
  @jeu        = nil   # Jeu string de la note (le texte après le tiret)
  @finger     = nil   # Le doigté éventuel
  @dyna       = nil   # Hash gérant la dynamique de la linote. Nil ou 
                      # la définition de :start, :start_intensite, :end
                      # et :end_intensite.
  @real_octave = nil  # L'octave réelle de la note, quelle que soit son
                      # delta. C'est en fait la somme de @octave et de
                      # @delta. La note "a'" par exemple obtiendra comme
                      # valeurs : 
                      # note:"a", delta:-1 octave:4 real_octave:3
  @octave     = nil   # Fixé par d'autre méthode ou à l'instanciation si
                      # dans les paramètres. Si on l'appelle par la
                      # méthode `octave', l'octave est compté à partir
                      # de l'octave 4 ou l'octave fournie, en ajoutant 
                      # le delta
  @delta      = nil   # Delta d'octave (un Fixnum, 0 par défaut ou quand
                      # la linote suit naturellement la précédente)
  @legato     = nil   # Valeur du légato (if any). Nil si pas de légato,
                      # 1: début de slure, 2: fin de slure, 3: début de
                      # légato, 4: fin de légato.
                      
  # Instanciation
  # --------------
  # @param  valeur  SOIT : (String)
  #                   La note pour initialiser, soit une note lilypond,
  #                   soit une valeur entière, correspondant à la note
  #                   La note lilypond peut avoir la forme : "aisis"
  #                 SOIT : (Fixnum)
  #                   La hauteur absolue de la note.
  #                 SOIT : (Hash)
  #                   Toutes les valeurs (cf. LINote::explode)
  # 
  # @param  params    Peut contenir différentes valeurs, telles que :
  #         - :tonalite   La tonalité du contexte de la note
  #         - :octave     La hauteur en octave de la note
  # 
  # @properties
  #           cf. ci-dessus
  # 
  def initialize valeur = nil, params = nil
    @note         = nil
    @delta        = 0
    @duration     = nil
    @dyna         = nil
    @legato       = nil
    @in_accord    = false
    get_from_valeur_or_params valeur, params
    case valeur.class.to_s
    when "Hash"
      set valeur
    when "String"
      ln = LINote::llp_to_linote(valeur)
      ln.set( params ) unless params.nil?
      params = ln.to_hash
    when "Fixnum"
      @note   = NOTE_INT_TO_STR[valeur][:natural] 
    end
    set params
  end
  
  # 
  def get_from_valeur_or_params valeur, params
    unless params.nil?
      @octave       = params[:octave]       if params.has_key? :octave
      @real_octave  = params[:real_octave]  if params.has_key? :real_octave
    end
    unless valeur.class != Hash
      @octave       = valeur[:octave]       if valeur.has_key? :octave
      @real_octave  = valeur[:real_octave]  if valeur.has_key? :real_octave
    end
    # puts "\n\nAPRÈS get_from_valeur_or_params:"
    # puts "= @octave: #{@octave}"
    # puts "= @real_octave: #{@real_octave}"
  end
  # => Permet de définir les valeurs
  # @usage      <linote>.set <hash_paires_prop_value>
  # 
  def set props
    set_params props
    if @note != nil
      if @note.length != 1
        hash = LINote::llp_to_linote( LINote::to_llp(@note) ).to_hash
        @note     = hash[:note]
        @alter    = hash[:alter]
        @duration = hash[:duration] unless hash[:duration].nil?
      end
    end
  end

  # => Return la valeur d'une propriété
  def get prop
    instance_variable_get("@#{prop}")
  end
  
  # =>  Retourne la valeur absolue de la note, en fonction de ses
  #     altération, de son octave et de son delta d'octave (qui peuvent
  #     être différents)
  # 
  # @note:      C3 a la valeur 0 (mais susceptible de changer pour
  #             correspondre aux notes midi)
  #             A0 = 21
  #             C4 = 60
  def abs
    return nil if self.note == "r"
    begin
      # puts "\nself.index: #{self.index}"
      # puts "self.real_octave: #{self.real_octave}"
      oct_ref = unless real_octave.nil? 
                  real_octave
                else
                  4 + (@delta || 0)
                end
      valeur = self.index + (oct_ref + 1) * 12
    rescue Exception => e
      puts "\n\nIMPOSSIBLE D'OBTENIR LA VALEUR ABSOLU DE :"
      puts "= Erreur: #{e.message}"
      puts "= #{self.inspect}"
      puts "= self.index: #{self.index}"
      puts "= self.real_octave: #{self.real_octave}"
      raise
    end
    # Traitement spécial pour le franchissement d'obstacle
    if self.note == "c" && self.bemol?
      valeur -= 12 
    elsif self.note == "b" && self.diese?
      valeur += 12
    end
    valeur
  end
  alias :to_midi :abs
  
  # => Retourne la durée de la LINote
  # 
  # @note: cette durée se trouve dans :duration pour une note normale
  # et dans :duree_post pour la dernière note d'un accord. Pour les 
  # autres notes de l'accord, s'il y a eu explosion (explode), elles se
  # trouvent dans la propriété @duree_chord. Pour l'obtenir, il faut
  # mettre la valeur de +absolue+ à true.
  # 
  # @param  absolue   Si true, la durée d'une note d'un accord est
  #                   retournée, même si elle n'a pas de durée affectée
  #                   à l'écriture. Par exemple, pour "<c e f>8", seule
  #                   la note "f" a une durée (@duree_post) définie. Mais
  #                   si la LINote a été obtenue par un explode de motif,
  #                   les autres notes contiennent dans leur propriété
  #                   @duree_chord leur durée (même la dernière)
  # 
  def duration absolue = false
    return @duration    unless @duration.nil?
    return @duree_post  unless @duree_post.nil? && absolue == true
    return @duree_chord
  end
  
  # =>  Retourne la valeur absolue de la durée de la note (pour calcul
  #     de mesures par exemple)
  #     Cette valeur est comptée sur la base d'une noire qui vaut 1.0
  #     Donc, par exemple, une ronde vaut 4.0, une blanche 2.0, etc.
  # 
  # @param  duree_defaut . La durée par défaut (peut-être héritée de la
  #                      . note précédente) dans le cas où duration
  #                      . renverrait une valeur nulle.
  #                      . SOIT : une durée string  (String)
  #                      . SOIT : une durée absolue (Float)
  # 
  # @note:  Si aucune durée n'est trouvée, on met une noire ("4")
  # 
  def duree_absolue duree_defaut = nil
    duree = duration(true)
    if duree.nil? || duree == "~"
      return duree_defaut if duree_defaut.class == Float
      duree = duree_defaut || "4"
    end
    return nil if duree.nil?
    duree.scan(/^([0-9]*)?([.]*)?(~)?$/){
      tout, nombre, points, tilde = [$&, $1, $2, $3]
      return duree_points_to_float nombre, points
    }
  end
  
  # =>  Retourne la durée absolue (flottant) en fonction de la durée
  #     définie par le +nombre+ (qui peut être un string) et les +points+
  # 
  def duree_points_to_float nombre, points
    valeur = 4.0 / nombre.to_i
    valeur_init = 0.0 + valeur
    points.length.times do |itime| 
      valeur += valeur_init / ( 2**(itime + 1) ) 
    end unless points.nil?
    valeur
  end

  # => Recompose le string à partir des données de la linote
  # 
  # @return le string des notes reconstituées
  # 
  # @param params   Paramètres optionnels.
  #                 Permettent par exemple de stipuler qu'il ne faut
  #                 par prendre certaines données, comme par exemple
  #                 la mark_delta
  #                 Dans ce cas, on indique dans params :
  #                   :except => {:mark_delta => true}
  # 
  # @note:  Contrairement à la méthode :to_s, :to_llp renvoie l'octave
  #         en delta d'octave, pas en marque relative.
  #         Soit la linote "c" à l'octave -1
  #           linote.to_llp   =>    "c,"
  #           linote.to_s     =>    "\\relative c, { c }"
  #
  # @note:  Cette méthode est utilisée pour l'instrument, en méthode
  #         finale pour composer le code pour LilyPond.
  #         Elle est également utilisée dans LINote::implode pour 
  #         recomposer une suite.
  # 
  def to_llp params = nil
    params ||= {}
    except = params[:except] || {}

    # puts "\n\nLINote à to_llp: #{self.inspect}"
    # puts "except: #{except.inspect}"
    
    note_llp = ""
    # Intensité de départ (if any)
    note_llp << mark_intensite_start
    # Marque d'accord
    # @TODO: je le laisse en 'pre' pour le moment, mais à l'avenir,
    # on pourra le supprimer si ce pre ne contient plus que la marque
    # de départ d'accord (le reste est géré par ailleurs)
    note_llp << @pre.to_s
    # Note simple
    note_llp << @note
    # Altération de la note
    note_llp << @alter.to_s
    # Delta d'octave (sauf indication contraire)
    note_llp << mark_delta unless except[:mark_delta] === true
    # Durée de la note (sauf indication contraire)
    note_llp << mark_duration unless except[:duration] === true
    # Marque de jeu (sauf indication contraire)
    note_llp << (@jeu.nil? ? '' : "-#{@jeu}") unless except[:jeu] === true
    # Doigté
    note_llp << @finger.to_s
    # Post-indications
    note_llp << @post.to_s
    # Durée post (par exemple pour un accord)
    note_llp << mark_duree_post unless except[:duree_post] === true
    # Marque de liaison (if any)
    note_llp << mark_legato
    # Marque de début de dynamique (if any)
    note_llp << mark_dyna_start 
    # Marque de fin de dynamique (if any)
    note_llp << mark_dyna_end

    # = débug =
    # puts "note_llp:#{note_llp}"
    # = / débug =
    
    return note_llp
  end
  
  
  # =>  Return la linote comme texte final lilypond
  #     P.e. "\relative c' { dis }"
  # @FIXME: cette méthode doit être mauvaise (trop simple, ne tient
  #         compte que de la note)
  def to_s
    note = to_llp( :except => { :octave => true } )
    "#{Score::mark_relative(@octave)} { #{note} }"
  end
  
  # =>  Définit le delta de +self+ pour que la linote suive +linote+ en
  #     fonction de leurs octaves respectives
  # 
  # @return   self
  def as_next_of linote, params = nil
    fatal_error(:param_method_linote_should_be_linote, :ln => self, 
                :method => "as_next_of") unless linote.class == LINote
    params ||= {}
    instrument = params[:instrument]
    
    # Octave naturelle de +self+ si elle suivait sans delta +linote+
    self_natural_octave = natural_octave_after linote, instrument
  
    # La différence d'octave pour savoir si un delta est nécessaire
    @delta = self.real_octave - self_natural_octave
    
    self
  end
  
  # =>  Retourne l'octave "naturelle" qu'aurait la linote +self+ si elle
  #     suivait la +linote+, sans delta
  #     Par exemple :
  #     GIVEN   Une linote de note "a" et d'octave 0
  #     WHEN    On demande l'octave naturelle d'une note "c"
  #     THEN    La méthode renvoie 1
  # 
  # @param  linote      Une instance de LINote
  # @param  instrument  Optionnellement, l'instance Instrument de 
  #                     l'instrument, pour connaitre les octaves par
  #                     défaut.
  # 
  # @return   Un entier Fixnum représentant l'octave naturelle de self
  # 
  def natural_octave_after linote, instrument = nil
    fatal_error(:param_method_linote_should_be_linote, :ln => self, 
      :method => "natural_octave_after") unless linote.class == LINote
    # Position de +self+ par rapport à +linote+, sans tenir compte
    # pour le moment de l'octave de linote
    # On demande à savoir si l'octave a été franchie (true en 2e param)
    result = self.note.au_dessus_de?( linote.note, true )
    au_dessus       = (result & 1) > 0
    new_octave      = (result & 2) > 0
    # Octave franchi, en cas de nouvelle octave
    add_octave      = new_octave ? (au_dessus ? 1 : -1) : 0
    # En fonction de l'octave de +linote+, l'octave qu'aurait +self+ 
    # sans delta
    linote.real_octave + add_octave
  end
  
  # => Retourne un clone de la LINote courante
  def clone
    LINote::new to_hash
  end
  
  # => Return la linote sous forme de hash
  # 
  def to_hash
    hash = {}
    [ :note, :alter, :delta, :duration, :pre, :post, :finger, :jeu,
      :duree_post, :dyna, :in_accord
    ].each do |prop|
      hash = hash.merge( prop => instance_variable_get("@#{prop}") )
    end
    # Propriétés qui doivent être éventuellement calculées
    hash = hash.merge :octave => octave, :real_octave => real_octave
  end
  
  # => Renvoie la note avec son altération
  # @usage :    <linote>.with_alter   => p.e. "deses"
  def with_alter
    "#{@note}#{@alter}"
  end
    
  # => Return la linote sous forme d'instance de Note
  # @TODO: SUPPRIMER CETTE MÉTHODE QUAND LA CLASSE Note SERA SUPPRIMÉE,
  # SI ELLE L'EST UN JOUR.
  def as_note
    Note::new @note, :octave => octave, :duration => @duration, :alter => @alter
  end
  
  # =>  Return l'OCTAVE RÉELLE de la LINote
  # 
  # @param  instrument  La classe de l'instrument optionnelle. 
  #                     Si définie, l'octave par défaut prise en 
  #                     référence peut varier suivant l'instrument.
  # 
  def real_octave instrument = nil
    prop = instrument.nil? ? "real_octave" : "real_octave_#{instrument.class}"
    get(prop.to_sym) || lambda {
      @delta = 0 if @delta.nil?
      real_oct = 
        oct_ref = instrument.nil? ? @octave : instrument.octave_defaut
        oct_ref + @delta unless oct_ref.nil?
      set prop => real_oct
      return real_oct
    }.call
  end
  
  # =>  Return l'octave de la note
  #     @ATTENTION: maintenant, cette octave ne représente plus l'octave
  #     réelle de la note, mais sa valeur sans le delta. C'est la
  #     propriété @real_octave qui contient l'octave absolue de la LINote
  # 
  # @return entier représentant l'octave de la note
  # 
  # @param  instrument    L'instrument (objet Instrument) optionnel,
  #                       définissant l'octave par défaut si nécessaire
  # 
  def octave instrument = nil
    if instrument.nil?
      @octave = if    @octave != nil      then @octave
                elsif @real_octave != nil && @delta != nil 
                  @real_octave - @delta
                else nil end
      # puts "\n\nOctave retourné par la méthode octave: #{@octave}"
      # puts "(real_octave: #{@real_octave})"
      return @octave
      # return @octave unless @octave.nil?
      # return (@real_octave - (@delta || 0)) unless @real_octave.nil?
      # return 4
    end
    get("octave_#{intrument.class}".to_sym) || lambda {
      oct = unless @real_octave.nil?
              @real_octave - @delta
            else
              instrument.octave_defaut
            end
      set "octave_#{intrument.class}".to_sym => oct
      return oct
    }.call
  end
  
  # =>  Return la marque à appliquer à la note pour la reconstituer
  # 
  def mark_duration
    return "" if @duration.nil? || in_accord?
    @duration.to_s
  end
  
  # => Return la marque de durée post pour la note à reconstituer
  def mark_duree_post
    # puts "--> mark_duree_post (@duree_post: #{@duree_post})"
    # puts "    self: #{self.inspect}"
    return @duree_chord if end_accord? && @duree_chord != nil
    return @duree_post  unless @duree_post.nil?
    return ""
  end

  # =>  Return la marque delta (apostrophe et virgules) en fonction
  #     du @delta de la linote
  def mark_delta
    LINote::mark_delta @delta
  end
  
  # -------------------------------------------------------------------
  #   Méthodes pour la dynamique
  def set_dyna params
    if params.nil? then @dyna = nil
    else
      if @dyna.nil?
        @dyna = { :crescendo => nil, :start => false, :end => false, 
                  :start_intensite => nil, :end_intensite => nil }
      end
      params[:crescendo] = false if params.delete(:decrescendo) === true
      params[:start] = true if params.has_key?(:crescendo) && params[:crescendo]
      [:crescendo, :start, :end, :start_intensite, :end_intensite
      ].each do |att|
        if params.has_key? att
          @dyna = @dyna.merge( att => params[att] )
        end
      end
    end
    return self
  end
  # Remet la dynamique à nil
  def erase_dynamique
    @dyna = nil
  end
  # Pose un début de crescendo sur la LINote
  def start_crescendo
    set_dyna :crescendo => true, :start => true
  end
  # Retourne true si la note marque un début de crescendo
  def crescendo_start?
    return false if @dyna.nil?
    return @dyna[:crescendo] === true && @dyna[:start] === true
  end
  # Pose une fin de dynamique sur la LINote
  def end_crescendo
    set_dyna :crescendo => nil, :end => true
  end
  alias :end_dynamique :end_crescendo
  # => Return true si la LINote marque la fin d'un crescendo
  def dynamique_end?
    return false if @dyna.nil?
    return @dyna[:crescendo].nil? && @dyna[:end] === true
  end
  alias :end_decrescendo :end_crescendo
  # Pose un début de decrescendo sur la LINote
  def start_decrescendo
    set_dyna :crescendo => false, :start => true
  end
  # => Return true si la LINote est le départ d'un decrescendo
  def decrescendo_start?
    return false if @dyna.nil?
    return @dyna[:crescendo] === false && @dyna[:start] === true
  end
  # => Return true si la LINote est un départ de dynamique
  def dynamique_start?
    return false if @dyna.nil?
    @dyna[:start] === true
  end
  # => Return true si la LINote est la fin d'une dynamique
  # Pose une intensité de départ sur la note
  def start_intensite intensite
    set_dyna :start_intensite => intensite, :start => true
  end
  # Pose une intensité de fin sur la LINote
  def end_intensite intensite
    set_dyna :end_intensite => intensite, :end => true
  end
  
  # =>  Retourne la marque de début de crescendo/decrescendo si
  #     nécessaire. Une chaine vide otherwise
  def mark_dyna_start
    return "" if @dyna.nil? || @dyna[:start] == false
    case @dyna[:crescendo]
    when nil then ""
    when true then "\\<"
    when false then "\\>"
    end
  end
  # =>  Retourne la marque de fin de crescendo/decrescendo si nécessaire
  #     Ou une chaine vide
  def mark_dyna_end
    return "" if @dyna.nil? || @dyna[:end] == false
    end_intensite = @dyna[:end_intensite]
    end_intensite.nil? ? "\\!" : end_intensite
  end
  # =>  Retourne l'intensité de départ de la note si nécessaire
  #     Ou une chaine vide
  def mark_intensite_start
    return "" if @dyna.nil? || @dyna[:start_intensite].nil?
    "\\#{@dyna[:start_intensite]} "
  end
  
  #   / fin méthodes pour la dynamique
  # -------------------------------------------------------------------

  # -------------------------------------------------------------------
  #   Méthodes de liaisons
  
  # =>  Méthode qui checke si la liaison est possible. Lève une erreur
  #     fatale dans le cas contraire.
  # 
  # @param  lk_str    Le nom string de la liaison, pour le message d'erreur
  # @param  value     La valeur de legato (donc celle qui n'est pas à
  #                   checker) et celle qui sera donnée à @legato si
  #                   tout passe (note: 'legato', ici, concerne le slure
  #                   aussi bien que le legato)
  # @produit  Définit @legato si OK
  # 
  def checkif_legato_enable lk_str, value
    begin
      @legato ||= 0
      # On s'en retourne immédiatement si @legato contient déjà cette
      # valeur
      return if (@legato & value) > 0
      # Principe : une note ne peut pas porter en même temps une fin
      # et un début de légato
      unless @legato.nil?
        if (legato_start? || slure_start?) \
            && ([BIT_END_SLURE, BIT_END_LEGATO].include? value )
          badstart = slure_start? ? 'start_slure' : 'start_legato'
          raise "#{lk_str}_unable_if_#{badstart}"
        elsif (slure_end? || legato_end?) \
              && ([BIT_START_SLURE, BIT_START_LEGATO].include? value )
          badend = slure_end? ? 'end_slure' : 'end_legato'
          raise "#{lk_str}_unable_if_#{badend}"
        end
      else
        @legato = 0
      end
    rescue Exception => e
      fatal_error(e.message, :linote => self.inspect)
    else
      @legato ||= 0
      @legato += value
    end
  end
  
  # => Place un début de slure sur la note (si c'est possible)
  def start_slure
    checkif_legato_enable 'slure', BIT_START_SLURE
  end
  # => Retourne true si la LINote est le début d'un slure
  def slure_start?
    return false if @legato.nil?
    (@legato & BIT_START_SLURE) > 0
  end
  # => Place une fin de slure sur la note (si c'est possible)
  def end_slure
    checkif_legato_enable 'end_slure', BIT_END_SLURE
  end
  # => return true si la LINote est la fin d'un slure
  def slure_end?
    return false if @legato.nil?
    (@legato & BIT_END_SLURE) > 0
  end
  # # => Supprime une marque de fin de slure (si elle existe)
  def erase_slure_end
    return unless slure_end?
    @legato -= BIT_END_SLURE
    @legato = nil if @legato == 0
  end
  # => Place un début de légato sur la note (si c'est possible)
  def start_legato
    checkif_legato_enable 'legato', BIT_START_LEGATO
  end
  
  # => Supprime une marque de fin de legato
  def erase_legato_end
    return unless legato_end?
    @legato -= BIT_END_LEGATO
    @legato = nil if @legato == 0
  end
  
  # => Return true si la LINote est le début d'un legato
  def legato_start?
    return false if @legato.nil?
    (@legato & BIT_START_LEGATO) > 0
  end
  # => Place une fin de legato sur la note (si c'est possible)
  def end_legato
    checkif_legato_enable 'end_legato', BIT_END_LEGATO
  end
  # Return true si la LINote est la fin d'un legato
  def legato_end?
    return false if @legato.nil?
    (@legato & BIT_END_LEGATO) > 0
  end
  
  # =>  Retourne la marque de legato (ou slure) éventuelle à poser sur
  #     la note
  def mark_legato
    mark = ""
    return mark if @legato.nil?
    mark << "\\(" if legato_start?
    (mark << "(") and return mark if slure_start?
    mark << ")"   if slure_end?
    mark << "\\)" if legato_end?
    mark
  end
  
  #   / Fin des méthodes de liaison
  # -------------------------------------------------------------------
  
  # => Return true si la LINote est un silence
  def rest?
    @note == "r"
  end
  # => Retourne true si la linote se trouve dans un accord
  def in_accord?
    @in_accord === true
  end
  # => Retourne true si c'est la première note d'un accord
  def start_accord?
    @pre =~ /</
  end
  # => Retourne true si la LINote est la fin d'un accord
  def end_accord?
    @post =~ />/
  end
  # Return true si la linote contient des dièses
  def diese?
    @alter != nil && @alter[0..1] == "is"
  end
  # Return true si la linote contient des bémols
  def bemol?
    @alter != nil && @alter[0..1] == "es"
  end
  
  # Return true si la linote courante, *sur la portée*, est au-dessus
  # de +note+ (si les deux notes, avec leurs altérations et leur delta,
  # s'enchaînaient, par exemple "a c")
  # 
  # @param  self    Une Linote simple
  # @param  linote  Soit une note string, soit une LINote
  # 
  # @return true/false
  # 
  # @note: jusqu'à présent, c'est la méthode la plus fiable
  # 
  def au_dessus_de? linote
    linote = linote.to_linote if linote.class == String

    # @fixme: peut-être qu'il faudra modifier le code ci-dessous 
    # maintenant que 'octaves_llp' a été supprimé, substitué par delta
    # qui est le nombre d'octave (par défaut 0, jamais nil)
    case linote.delta
    when 1..10    : false
    when -10..-1  : true
    else # pas de delta => Il faut calculer
      return  case linote.index_diat - self.index_diat
              when 0    then false
              when 1..3, -6..-4 then false
              when 4..6, -3..-1 then true
              end
    end
  end
  alias :above? :au_dessus_de?

  # Return true si la linote courante, *en valeur absolue*, est au-dessus
  # de +note+
  # 
  # @param  self    Une Linote
  # @param  linote  Soit une note string, soit une LINote
  # 
  # @note : sauf avis contraire (:octave spécifiée), on suppose que les
  #         deux notes sont à l'octave 4
  # 
  # @return true/false
  # 
  def plus_haute_que? linote
    linote = linote.to_linote if linote.class == String
    self.abs > linote.abs
  end
  alias :higher_than? :plus_haute_que?
  
  # Return true si la note courante est après la li-note +ninote+
  # ATTENTION : il ne s'agit pas du *son* mais seulement du *nom* de
  # la note dans la gamme diatonique. Ici, Mi#.after? Fab # renverra
  # false alors que Mi# est pourtant après Fab pour la même octave donné
  # 
  # @return true/false ou nil si l'une des @note n'est pas définie
  # 
  # @note:  utiliser la méthode plus_haute_que? pour savoir si, en valeur
  #         absolue de note, elle est au-dessus.
  # 
  def after? linote
    return nil if @note.nil? || linote.note.nil?
    return self.index_diat >= linote.index_diat
  end
  
  # =>  Return l'index (Fixnum) absolu de la note dans la gamme 
  #     chromatique (en tenant compte de ses altérations)
  # @return un nombre de 0 ("c") à 11 ("b")
  def index
    @index ||= NOTE_STR_TO_INT["#{@note}#{@alter}"]
  end
  
  # =>  Return l'index diatonique de la linote (c'est-à-dire son index
  #     dans la gamme diatonique, c'est-à-dire sans tenir compte de ses
  #     altérations)
  def index_diat
    @index_diat ||= GAMME_DIATONIQUE.index(self.note)
  end
  
  # -------------------------------------------------------------------
  #   Méthodes de changement de hauteur
  # -------------------------------------------------------------------

  # =>  Retourne une nouvelle linote haussée du nombre de degrés voulu
  #     dans la tonalité courante
  # 
  # @param    degres      Nombre de degrés dont il faut surélever la note
  # 
  # @note     Si le nombre de degrés est supérieur à 7, on modifie aussi
  #           l'octave de la LINote.
  # @note     La même méthode est utilisée pour :down, avec un argument
  #           négatif.
  # 
  # @requis   SCORE::key  Tonalité courante. Do par défaut
  # @return   La nouvelle LINote réhaussée
  # 
  def up degres
    new_ln      = self.clone
    index_self  = self.index_diat
    index_new   = (index_self + degres) % 7
    octave_sup  = degres / 7
    new_ln.set :note  => GAMME_DIATONIQUE[index_new]
    new_ln.set :alter => LINote::alteration_for_notes_in_key[new_ln.note]
    unless octave_sup == 0
      new_ln.set :real_octave => (new_ln.real_octave || 4) + octave_sup
      new_ln.set :octave      => (new_ln.octave      || 4) + octave_sup
    end
    new_ln
  end
  # =>  Retourne une nouvelle linote baissée du nombre de degrés voulu
  #     dans la tonalité courante (ou DO)
  # 
  # @note: Paramètres identiques à :up
  # 
  def down degres
    up -degres
  end
  
  # =>  Return la note baissée de +demitons+ demi-tons dans le contexte
  #     défini par +params+
  # @param demitons     Integer, nombre de demi-tons
  # @param params       Contient :tonalite qui définit la tonalité
  # 
  def moins demitons, params = nil
    note_int = self.index
    while note_int < demitons
      note_int += 12
    end
    LINote::note_str_in_context(note_int - demitons, params)
  end
  # => Return la note montée de +demitons+ demi-tons
  # cf. `moins' pour les arguments
  def plus demitons, params = nil
    LINote::note_str_in_context(index + demitons, params)
  end
  
  # => Return le nom str en fonction du context (cf. la méthode statique)
  def str_in_context context
    LINote::note_str_in_context index, context
  end
end