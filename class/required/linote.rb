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
    REG_NOTE = %r{<?[a-gr](?:(?:es|is){1,2})?>?}
    
    # Expression régulière pour repérer un accord
    # 
    REG_CHORD = %r{(<[a-gr](?:[^>]+)>)}
    
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
  #                     complexe (p.e. "cisis,,8.-^(" )
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
      tout, pre, note, alter, octave, duree, jeu, finger, post, duree_post,
      mark_dyna = 
        [$&, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10]
        
      # Étude du jeu
      # ------------
      unless jeu.to_s.blank?
        jeu = jeu[1..-1] # Pour retirer le '-' du départ
      end
      unless finger.to_s.blank?
        finger = finger[1..-1] # Pour retirer le '-' du départ
      end
      # Composition de la linote
      # ------------------------
      return LINote::new(
        :note => note, :duration => duree, :duree_post => duree_post, 
        :octave_llp => octave, :delta => octaves_from_llp(octave),
        :pre  => pre,  :alter => alter, :jeu => jeu, :post => post,
        :dynamique => mark_dyna,
        :finger => finger
        )
    }
    # Si on passe ici, c'est que le motif n'a pas été trouvé, que
    # +note_llp+ n'était donc pas au bon format
    fatal_error(:not_note_llp, :note => note_llp)
  end
  # => Return les données notes du motif +str+ (motif LilyPond)
  # ------------------------------------------------------------
  # @param  str   Un string contenant les notes à analyser
  #               OU une instance de Motif
  # 
  # @return Une liste d'instance LINote : cf. l'instance pour le 
  #         détail des propriétés
  # 
  def self.explode str
    data = []
    case str.class.to_s
    when "String" then ary_str = str.split(' ')
    when "Motif"  then ary_str = str.to_llp.split(' ')
    else fatal_error( :bad_type_for_args, 
                      :method => "LINote::explode",
                      :good => "String ou Motif", 
                      :bad => str.class.to_s)
    end
    ary_str.each do |membre|
      data << llp_to_linote( membre )
    end
    data
  end
  
  # =>  Reconstitue le string LilyPond à partir de la liste des
  #     Linotes envoyées
  def self.implode liste_linotes
    liste_linotes.collect do |linote|
      linote.to_llp
    end.join(' ')
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

    oui = $DEBUG === true
    
    puts "\n\n=== DÉBUG ON ===" if oui

    # Intervalle exact (nombre de demi-ton) entre les deux motifs
    intervalle = intervalle_between( motif1, motif2 )

    if oui
      puts "intervalle entre:\n\tMOTIF 1: #{motif1.inspect}\n\tMOTIF 2: #{motif2.inspect}"
      puts "==> #{intervalle}"
    end
    
    if intervalle.between?(-6, 6)
      suite_motif2 = motif2.notes_with_duree
    else
      mark            = intervalle > 0 ? "'" : ","
      distance        = intervalle - 6
      nombre_octaves  = (distance / 12) + 1
      mark_octaves    = Score::octave_as_llp nombre_octaves
      motif2_exploded = explode motif2
      # @note : on ne doit pas poser le delta d'octave sur un
      # silence, donc on cherche la première note
      i = -1
      while motif2_exploded[ i+=1 ].rest? do end
      motif2_exploded[i].instance_variable_set("@octave_llp", mark_octaves)

      # On recompose le motif
      suite_motif2 = implode( motif2_exploded )
      
      # if oui
      #   puts "-----------------------------------------"
      #   puts "L'intervalle est < -6 ou > 6"
      #   puts "=> On doit placer des ' ou ,"
      #   puts "Mark = #{mark}"
      #   puts "Distance = #{distance}"
      #   puts "Nombre d'octaves = #{nombre_octaves}"
      #   puts "Marque octaves   = #{mark_octaves}"
      #   puts "suite_motif2 obtenu: #{suite_motif2}"
      #   puts "-----------------------------------------"
      # end
    end
        
    # Motif assemblé renvoyé
    # "#{motif1.notes_with_duree} #{suite_motif2}"
    "#{motif1.to_llp} #{suite_motif2}"
    
  end

  # =>  Return l'intervalle (nombre de demi-tons) entre le +motif1+ et
  #     le +motif2+
  # 
  # @note: la valeur sera positive si +motif2+ est plus haut que
  # +motif1+, négative dans le cas contraire
  # 
  def self.intervalle_between motif1, motif2
    Liby::raise_unless_motif "LINote::intervalle_between", motif1, motif2
    return motif2.first_note.abs - motif1.last_note.abs
  end

  # =>  Pose une marque de début (donc après la première note) et de fin
  #     (donc après la dernière note) sur les +notes+
  # 
  # @return   +notes+ modifié
  # 
  # @note: ne cherche que les notes, pas les silences
  # 
  def self.pose_first_and_last_note notes, markin, markout
    dmotif = notes.split(' ') # => vers des notes mais aussi des marques
    ifirst = 0
    while dmotif[ifirst].match(/^[a-g]/).nil? do ifirst += 1 end
    dmotif[ifirst] = "#{dmotif[ifirst]}#{markin}"
    ilast = dmotif.count - 1
    while dmotif[ilast].match(/^[a-g]/).nil? do ilast -= 1 end
    dmotif[ilast] = "#{dmotif[ilast]}#{markout}"
    dmotif.join(' ')
  end



  # =>  Return la valeur string de la note en fonction du +context+
  #     soumis.
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
  def self.octaves_from_llp oct_llp
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

  # =>  Retourne le motif +motif+ où toutes les notes auront leur
  #     durée fixée à +duree+
  # 
  # @param  notes     Un string représentant la suite de notes à 
  #                   "duréifier"
  # @param  duree     La durée à appliquer, soit un nombre (p.e. 4) soit
  #                   un string (p.e. "4."). Si nil, le motif est
  #                   renvoyé tel quel.
  # 
  # @return Le motif corrigé ou raise une erreur fatale si un des
  #         argument est non conforme.
  # 
  # @note : attention, pour le moment, la recherche des notes n'est
  # pas forcément pleinement opérationnelle. @todo: je pourrai la mettre
  # en place lorsque j'aurais fait le tour de toutes les syntaxes de 
  # lilypond
  # 
  def self.fixe_notes_length notes, duree
    
    return notes if duree.nil?
    
    # Contrôle de la durée
    # ---------------------
    fatal_error(:invalid_duree_notes) if
      ! [Fixnum, String].include?(duree.class) \
      || duree.class == Fixnum && (duree < 1 || duree > 2000) \
      || duree.class == String && (duree.gsub(/[0-9]+\.?/, '') != "")
    
    # Contrôle du motif
    # ------------------
    fatal_error(:invalid_motif, :bad => notes.inspect) if notes.class != String
    
    # Affectation des durées
    # -----------------------
    # @note : contrairement à ce qui était fait avant, on n'applique
    # la durée que sur la première note, sauf si c'est un accord, dans
    # lequel cas il faut mettre la durée à la fin de l'accord.
    unless notes.start_with? '<'
      notes.sub(/^(#{REG_NOTE})/){ "#{$1}#{duree}"}
    else
      # Accord en début de notes
      notes.sub(/^(#{REG_CHORD})/){"#{$1}#{duree}"}
    end
  end
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :note, :duration, :octave_llp, :alter, :delta
  
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
  @octave_llp = nil   # Le delta d'octave, au format LLP (p.e. « '' »)
  @jeu        = nil   # Jeu string de la note (le texte après le tiret)
  @finger     = nil   # Le doigté éventuel
  @dynamique  = nil   # Éventuellement la marque de dynamique (quelque
                      # chose comme « \\! » ou « \\< » ou « \\fff »)
  
  @octave     = nil   # Fixé par d'autre méthode ou à l'instanciation si
                      # dans les paramètres. Si on l'appelle par la
                      # méthode `octave', l'octave est compté à partir
                      # de l'octave 3, en ajoutant le delta
  @delta      = nil   # Delta d'octave (calculé en général d'après 
                      # la valeur de @octave_llp)
                      
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
  #           :note     La note anglo-saxonne simple (seulement a-g)
  #                     0 si c'est un silence.
  #           :alter    Les altérations éventuelles / ""
  #                     "is" ou "isis" ou "es" ou "eses" ou ""
  #           :duration    La durée de la note / nil
  #           :octave_llp Le delta d'octave, au format lilypond
  #           :pre      Ce qu'il y a avant la note (p.e. "<" pour les
  #                     accord)
  #           :post     Ce qu'il y a après la note (p.e. ">" pour la
  #                     dernière note d'un accord)
  #           :finger   Le doigté indiqué
  #           :jeu      L'indication de jeu sur la note.
  # 
  def initialize valeur = nil, params = nil
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
    else
      @note_str = nil
      @note_int = nil
      @note     = nil
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
    valeur = self.index + (self.octave + 1) * 12
    # Traitement spécial pour le franchissement d'obstacle
    if self.note == "c" && self.bemol?
      valeur -= 12 
    elsif self.note == "b" && self.diese?
      valeur += 12
    end
    valeur
  end
  alias :to_midi :abs

  # => Recompose le string à partir des données de la linote
  # 
  # @return le string des notes reconstituées
  # 
  # @param params   Paramètres optionnels.
  #                 Permettent par exemple de stipuler qu'il ne faut
  #                 par prendre certaines données, comme par exemple
  #                 l'octave_llp
  #                 Dans ce cas, on indique dans params :
  #                   :except => {:octave_llp => true}
  # 
  # @note : contrairement à la méthode :to_s, :to_llp renvoie l'octave
  # en delta d'octave, pas en marque relative.
  #   Soit la linote "c" à l'octave -1
  #     linote.to_llp   =>    "c,"
  #     linote.to_s     =>    "\\relative c, { c }"
  # 
  def to_llp params = nil
    params ||= {}
    except = params[:except] || {}
    
    note_llp = "#{@pre}#{@note}#{@alter}"
    note_llp << "#{@octave_llp}" unless except[:octave_llp]  === true
    note_llp << "#{@duration}"   unless except[:duration]    === true
    unless except[:jeu] === true
      jeu = @jeu.nil? ? "" : "-#{@jeu}"
      note_llp << jeu
    end
    note_llp << "#{@finger}#{@post}#{@duree_post}#{@dynamique}"
    return note_llp
  end
  # alias :to_s :to_llp
  
  # =>  Return la linote comme texte final lilypond
  #     P.e. "\relative c' { dis }"
  def to_s
    note = to_llp( :except => { :octave => true } )
    "#{Score::mark_relative(@octave)} { #{note} }"
  end
  
  # => Return la linote sous forme de hash
  # 
  def to_hash
    hash = {}
    [:note, :alter, :octave_llp, :duration, :pre, :post, :finger, :jeu
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
  # =>  Return l'octave de la note (le calcule d'après octave_llp si
  #     non défini, en partant de l'octave 3)
  # @return entier représentant l'octave de la note
  def octave
    # puts "\n@octave_llp: #{@octave_llp}\n=> octave from llp: #{LINote::octaves_from_llp(@octave_llp)}"
    @octave ||= 3 + delta
  end
  def delta
    @delta ||= LINote::octaves_from_llp( @octave_llp )
  end
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
  #         deux notes sont à l'octave 3
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