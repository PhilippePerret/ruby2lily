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
  
  # =>  Définit et retourne les altérations des notes dans la tonalité
  #     +key+ fournie
  def self.alterations_notes_in_key key
    # @todo: il faut vérifier que la tonalité existe
    key ||= "C"
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
  
  # => Return une LINote d'après le string LilyPond +note_llp+
  # 
  # @param  note_llp    Un string de note LilyPond, qui peut être
  #                     complexe (p.e. « cisis,,8.-^( » ), mais en tout
  #                     cas une seule.
  # 
  # @return Une Linote contenant toutes les données
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
        
      # Étude du jeu et du doigté
      # -------------------------
      # (pour retirer le tiret qui les précède)
      jeu     = jeu[1..-1]    unless jeu.to_s.blank?
      finger  = finger[1..-1] unless finger.to_s.blank?

      # Composition de la linote
      # ------------------------
      return LINote::new(
        :note => note, :duration => duree, :duree_post => duree_post, 
        :delta => delta_from_markdelta(mark_delta),
        :pre  => pre,  :alter => alter, :jeu => jeu, :post => post,
        :dynamique => mark_dyna, :finger => finger
        )
    }
    # Si on passe ici, c'est que le motif n'a pas été trouvé, que
    # +note_llp+ n'était donc pas au bon format
    fatal_error(:not_note_llp, :note => note_llp)
  end
  
  # => Return les données notes du motif +str+ (motif LilyPond)
  # ------------------------------------------------------------
  # @param  some  Un string contenant les notes à analyser
  #               OU une instance de Motif
  # 
  # @return Une liste d'instance LINote : cf. l'instance pour le 
  #         détail des propriétés
  # 
  def self.explode some
    data = []
    # puts "\n\n-->LINote::explode"
    # puts "= Class de some: #{some.class}"
    ary_str = case some.class.to_s
              when "String" then some.split(' ')
              when "Motif"  then 
                current_octave = some.octave
                # puts "= Je mets current_octave à #{current_octave}"
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
      if ln.pre == "<"
        # On rentre dans un accord
        accord_start  = 0 + inote
        in_accord     = true
      elsif in_accord && ln.post == ">"
        # Dernière note d'un accord
        # => Il faut prendre sa durée (if any) et la mettre à toutes
        # les notes de l'accord
        duree = ln.duration
        unless duree.nil?
          (accord_start..(inote - 1)).each do |i|
            data[i].set :duree_in_chord => duree
          end
        end
        in_accord = false
      end
      
      # Réglage de l'octave
      # --------------------
      # On doit calculer l'octave courante sauf si c'est la première
      # linote et sauf si c'est la note d'un accord hors première
      unless inote == 0 || (in_accord && inote != accord_start)
        current_octave = ln.natural_octave_after(data[inote - 1])
      end
      ln.set :octave => current_octave
      
      # Ajout à la liste des linotes
      # -----------------------------
      data << ln
      inote += 1
    end
    data
  end
  
  # =>  Reconstitue le string LilyPond à partir de la liste des
  #     Linotes envoyées
  def self.implode liste_linotes
    liste_linotes.collect { |linote| linote.to_llp }.join(' ')
  end
  
  # =>  Return +notes+ avec '#' et 'b' pour dièse et bémol en 'is' et
  #     'es' et les notes italiennes remplacées par leur valeur
  #     anglosaxonne.
  # @param  notes   Un string de note
  # @todo: on devrait traiter ici les octaves peut-être ajoutés au
  # string envoyé (p.e. "c'"). Mais comment s'en sortir sachant que 
  # apostrope et virgule ne sont que des delta d'octaves ? et que
  # cette méthodes statique ne renvoie que la note ?
  # => C'est la méthode appelant cette méthode qui doit s'en charger.
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
    fatal_error(:bad_type_for_args, 
		  :good => "Motif", :bad => motif1.class.to_s, 
		  :method => "LINote::join") if motif1.class != Motif
    fatal_error(:bad_type_for_args, 
		  :good => "Motif", :bad => motif2.class.to_s, 
		  :method => "LINote::join") if motif2.class != Motif
			
    # On prend la première et la dernière note
    # -----------------------------------------
    # @note: dans le cas où le motif ne contiendrait que des silences,
    # la linote renvoyée sera nulle. Dans ce cas, on doit quand même
    # prendre son octave.
    # 
    ln_avant = motif1.last_note( strict = true )
    ln_apres = motif2.first_note( strict = true )
    
    diff_octave = 
      if ln_avant.nil? && ln_apres.nil? then 0
      elsif ln_avant.nil? || ln_apres.nil?
        motif2.octave - motif1.octave
      else
        ln_apres.octave - ln_apres.natural_octave_after( ln_avant )
      end
    
    unless diff_octave == 0
      # =>  On doit ajouter diff_octave à la note après (diff_octave peut
      #     être négatif)
      #     Ce nombre d'octaves sera mis en delta dans le motif. Par ex.,
      #     si la différence est de 2, il faudra ajouter « '' » à la 
      #     première note du motif 2
      motif2_exploded = motif2.explode
      i = -1
      while motif2_exploded[ i+=1 ].rest? do end
      motif2_exploded[i].set :delta => diff_octave
    end
    suite_motif2 = implode( motif2.exploded )
    
    # return "#{motif1.to_llp} #{suite_motif2}"
    return "#{motif1.simple_notes} #{suite_motif2}"
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
  # @todo:  Il faudrait un paramètre pour modifier la note ci-dessus : on
  #         devrait pouvoir placer la marque sur un silence, exceptionnellement
  # 
  def self.post_first_and_last_note notes, markin, markout
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
  # @note:  Contrairement à post_first_note, le signe est ajouté AVANT
  #         le signe qui peut déjà se trouver dans la linote
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
  # @note:  Contrairement à pre_first_note, le signe est ajouté APRÈS
  #         le post déjà défini.
  # 
  def self.post_first_note some, sig
    some = as_array_of_linotes(some)
    some.each do |ln|
      unless ln.rest?
        ln.set(:post => sig) and break if ln.post.nil?
        # Si @post contient déjà le signe, on ne fait rien
        deja_le_sig = 
              (ln.post[0..sig.length - 1] == sig) \
          ||  (ln.post[-sig.length..-1]   == sig)
        ln.set(:post => "#{ln.post}#{sig}") unless deja_le_sig
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
              :duree_post, :duree_in_chord, :dyna
  
  @note_str = nil   # La note string (p.e. "g" ou "fis" ou "eb" ou "g#")
  @note_int = nil   # La note, exprimé par un entier
  
  @note       = nil   # La note simple (SEULEMENT a-g / r)
  @alter      = nil   # Altération de la note (p.e. "eses" ou "is")
  @pre        = nil   # Ce qui précède la note (p.e. '<')
  @post       = nil   # Ce qui suit la note (p.e. '>' ou ')')
  @duration   = nil   # La durée de la note (p.e. "4.")
  @duree_post = nil   # La "post-durée", p.e. après un accord, si la
                      # dernière note : "<.... a>8.", "8." est la 
                      # duree_post (@note: ça sert pour :explode et
                      # :implode)
  @duree_in_chord=nil # Lors de l'explosion (explode), si la méthode
                      # rencontre un accord, elle affecte à toutes les
                      # notes la durée trouvée pour la dernière.
                      # Cette propriété n'existe donc que pour les
                      # notes des accords
  @mark_delta = nil   # Le delta d'octave, au format LLP (p.e. « '' »)
                      # Calculée d'après @delta par la méthode éponyme
  @jeu        = nil   # Jeu string de la note (le texte après le tiret)
  @finger     = nil   # Le doigté éventuel
  @dynamique  = nil   # Éventuellement la marque de dynamique (quelque
                      # chose comme « \\! » ou « \\< » ou « \\fff »)
                      # Doit devenir obsolète.
  @dyna       = nil   # Hash gérant la dynamique de la linote. Nil ou 
                      # la définition de :start, :start_intensite, :end
                      # et :end_intensite.
  @octave     = nil   # Fixé par d'autre méthode ou à l'instanciation si
                      # dans les paramètres. Si on l'appelle par la
                      # méthode `octave', l'octave est compté à partir
                      # de l'octave 4 ou l'octave fournie, en ajoutant 
                      # le delta
  @delta      = nil   # Delta d'octave (un Fixnum, 0 par défaut ou quand
                      # la linote suit naturellement la précédente)
                      
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
    @note_str   = nil
    @note_int   = nil
    @note       = nil
    @delta      = 0
    @duration   = nil
    @octave     = nil
    @dyna       = nil
    case valeur.class.to_s
    when "Hash"
      set valeur
    when "String"
      @note_str = valeur
      params ||= {}
      params  = LINote::llp_to_linote(@note_str).to_hash.merge( params )
    when "Fixnum"
      @note_int = valeur
      @note_str = str_in_context params
      @note     = @note_str[0..0]
    end
    set params
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
      @note_int = NOTE_STR_TO_INT["#{@note}#{@alter}"]
    end
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
      valeur = self.index + (self.octave + 1) * 12
    rescue Exception => e
      puts "\n\nIMPOSSIBLE D'OBTENIR LA VALEUR ABSOLU DE :"
      puts "= Erreur: #{e.message}"
      puts "= #{self.inspect}"
      puts "= self.index: #{self.index}"
      puts "= self.octave: #{self.octave}"
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
  # trouvent dans la propriété @duree_in_chord. Pour l'obtenir, il faut
  # mettre la valeur de +absolue+ à true.
  # 
  # @param  absolue   Si true, la durée d'une note d'un accord est
  #                   retournée, même si elle n'a pas de durée affectée
  #                   à l'écriture. Par exemple, pour "<c e f>8", seule
  #                   la note "f" a une durée (@duree_post) définie. Mais
  #                   si la LINote a été obtenue par un explode de motif,
  #                   les autres notes contiennent dans leur propriété
  #                   @duree_in_chord leur durée (même la dernière)
  # 
  def duration absolue = false
    return @duration    unless @duration.nil?
    return @duree_post  unless @duree_post.nil? && absolue == true
    return @duree_in_chord
  end
  
  # =>  Retourne la valeur absolue de la durée de la note (pour calcul
  #     de mesures par exemple)
  #     Cette valeur est comptée sur la base d'une noire qui vaut 1.0
  #     Donc, par exemple, une ronde vaut 4.0, une blanche 2.0, etc.
  def duree_absolue
    duree = duration(true)
    return nil if duree.nil?
    valeur = 0
    duree.scan(/^([0-9]*)?([.]*)?(~)?$/){
      tout, nombre, points, tilde = [$&, $1, $2, $3]
      valeur = 4.0 / nombre.to_i
      valeur_init = 0.0 + valeur
      unless points.nil?
        points.length.times { |itime| valeur += valeur_init / (2**(itime + 1)) }
      end
    }
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
  # 
  def to_llp params = nil
    params ||= {}
    except = params[:except] || {}
    
    note_llp = "#{@pre}#{@note}#{@alter}"
    note_llp << "#{mark_delta}" unless except[:mark_delta]  === true
    note_llp << "#{@duration}"  unless except[:duration]    === true
    unless except[:jeu] === true
      jeu = @jeu.nil? ? "" : "-#{@jeu}"
      note_llp << jeu
    end
    note_llp << "#{@finger}#{@post}#{@duree_post}#{@dynamique}"
    return note_llp
  end
  
  # =>  Return la linote comme texte final lilypond
  #     P.e. "\relative c' { dis }"
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
    @delta = self.octave - self_natural_octave
    
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
    linote.octave(instrument) + add_octave
  end
  # => Return la linote sous forme de hash
  # 
  def to_hash
    hash = {}
    [:note, :alter, :delta, :duration, :pre, :post, :finger, :jeu,
      :duree_post, :dyna
    ].each do |prop|
      hash = hash.merge( prop => instance_variable_get("@#{prop}") )
    end
    hash = hash.merge :octave => octave
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
  # =>  Return l'octave de la note (le calcule d'après delta si
  #     non défini, en partant de l'octave 4)
  # 
  # @return entier représentant l'octave de la note
  # 
  # @param  instrument    L'instrument (objet Instrument) optionnel,
  #                       définissant l'octave par défaut
  # 
  def octave instrument = nil
    @octave ||= lambda {
        octave_defaut = unless instrument.nil?
                          instrument.octave_defaut || 4
                        else 4 end
        ( octave_defaut + delta )
      }.call
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
      params[:start] = true if params.has_key? :crescendo
      [:crescendo, :start, :end, :start_intensite, :end_intensite
      ].each do |att|
        if params.has_key? att
          @dyna = @dyna.merge( att => params[att] )
        end
      end
    end
  end
  # Pose un début de crescendo sur la LINote
  def start_crescendo
    set_dyna :crescendo => true, :start => true
  end
  # Pose une fin de dynamique sur la LINote
  def end_crescendo
    set_dyna :crescendo => true, :end => true
  end
  alias :end_decrescendo :end_crescendo
  # Pose un début de decrescendo sur la LINote
  def start_decrescendo
    set_dyna :crescendo => false, :start => true
  end
  # Pose une intensité de départ sur la note
  def start_intensite intensite
    set_dyna :start_intensite => intensite
  end
  # Pose une intensité de fin sur la LINote
  def end_intensite intensite
    set_dyna :end_intensite => intensite
  end
  #   / fin méthodes pour la dynamique
  # -------------------------------------------------------------------

  # => Return true si la LINote est un silence
  def rest?
    @note == "r"
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
    @note_int
  end
  
  # =>  Return l'index diatonique de la linote (c'est-à-dire son index
  #     dans la gamme diatonique, c'est-à-dire sans tenir compte de ses
  #     altérations)
  def index_diat
    @index_diat ||= GAMME_DIATONIQUE.index(self.note)
  end
  
  # =>  Return la note baissée de +demitons+ demi-tons dans le contexte
  #     défini par +params+
  # @param demitons     Integer, nombre de demi-tons
  # @param params       Contient :tonalite qui définit la tonalité
  # 
  def moins demitons, params = nil
    while @note_int < demitons
      @note_int += 12
    end
    LINote::note_str_in_context(@note_int - demitons, params)
  end
  # => Return la note montée de +demitons+ demi-tons
  # cf. `moins' pour les arguments
  def plus demitons, params = nil
    # debug "\n@note_str:#{@note_str} - @note_int:#{@note_int} - demitons:#{demitons} - params:#{params.inspect}"
    LINote::note_str_in_context(@note_int + demitons, params)
  end
  
  # => Return le nom str en fonction du context (cf. la méthode statique)
  def str_in_context context
    LINote::note_str_in_context @note_int, context
  end
end