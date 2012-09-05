# 
# Class LINote
# 
# Permet toutes les opérations sur les notes
# 
require 'String'
require 'note'

class LINote
  
  # -------------------------------------------------------------------
  #   Constantes
  # -------------------------------------------------------------------

  unless defined? NOTE_STR_TO_INT
    # Table de correspondance entre la note en string ("g") et la valeur
    # entière
    NOTE_STR_TO_INT = {
      "deses" => 0, "bis"   => 0, "c"   => 0,
      "cis"   => 1,               "des" => 1, 
      "eeses" => 2, "cisis" => 2, "d"   => 2,
      "dis"   => 3, "feses" => 3, "ees" => 3,
      "disis" => 4, "fes"   => 4, "e"   => 4,
      "eis"   => 5, "geses" => 5, "f"   => 5,
      "ges"   => 6,               "fis" => 6,
      "fisis" => 7, "aeses" => 7, "g"   => 7, 
      "gis"   => 8,               "aes" => 8,
      "gisis" => 9, "beses" => 9, "a"   => 9,
      "ais"   => 10,              "bes" => 10,
      "aisis" => 11, "ces"  => 11, "b"  => 11
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
    REG_NOTE = %r{[a-g](?:(?:es|is){1,2})?}
    
    # Altérations normales vers altérations lilypond
    ALTERATIONS = { '#' => 'is', '##' => 'isis', 'b' => 'es', 
                    'bb' => 'eses'}
    
    # Expression régulière pour transformer les italienne en 
    # anglosaxonnes
    # @note: c'est la constante Note::ITAL_TO_ANGLO qui permettra
    # d'obtenir la note anglosaxonne.
    REG_ITAL_TO_LLP = %r{\b(ut|do|re|ré|mi|fa|sol|la|si)}
  end # / si constantes déjà définies (tests)
  
  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------
    
  # =>  Return +notes+ avec '#' et 'b' pour dièse et bémol en 'is' et
  #     'es' et les notes italiennes remplacées par leur valeur
  #     anglosaxonne.
  # @param  notes   Un string de note
  # @todo: implémenter LINote::to_llp pour traiter Note, Motif, etc. ?
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
  
  # => Return le texte "\relative c..." correspondant à l'+octave+
  def self.mark_relative octave
    "\\relative #{mark_octave(octave)}"
  end
  
  # => Retourne la marque d'octave (à ajouter à \\relative)
  # @param  octaves   Le nombre d'octaves
  # @return "c" + le nombre de virgules ou d'apostrophes nécessaires
  def self.mark_octave octaves = 0
    "c#{octave_as_llp(octaves)}"
  end
  
  # => Retourne l'octave exprimée en virgules ou apostrophe
  def self.octave_as_llp oct
    return "" if oct == 0
    mk = oct > 0 ? "'" : ","
    mk.fois(oct.abs)
  end

  # =>  Retourne le motif +motif+ où toutes les notes auront leur
  #     durée fixée à +duree+
  # 
  # @param  motif     Un string représentant le motif à corriger
  #                   Note : ce n'est pas une instance Motif
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
  def self.fixe_notes_length motif, duree
    
    return motif if duree.nil?
    
    # Contrôle de la durée
    # ---------------------
    fatal_error(:invalid_duree_notes) if
      ! [Fixnum, String].include?(duree.class) \
      || duree.class == Fixnum && (duree < 1 || duree > 2000) \
      || duree.class == String && (duree.gsub(/[0-9]+\.?/, '') != "")
    
    # Contrôle du motif
    # ------------------
    fatal_error(:invalid_motif, :bad => motif) if motif.class != String
    
    # Affectation des durées
    # -----------------------
    liste_notes = []
    motif.split(' ').each do |membre|
      membre.gsub(/^(r|#{LINote::REG_NOTE})(?:[0-9]{1,3})?(.*?)$/){
        note_ou_rest, suite = [$1, $2]
        liste_notes << "#{note_ou_rest}#{duree.to_s}#{suite}"
      }
    end
    liste_notes.join(' ')
  end
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  @note_str = nil   # La note string (p.e. "g" ou "fis" ou "eb" ou "g#")
  @note_int = nil   # La note, exprimé par un entier
  
  # Instanciation
  # --------------
  # @param  valeur    La note pour initialiser, soit une note lilypond,
  #                   soit une valeur entière, correspondant à la note
  #                   La note lilypond peut avoir la forme : "aisis"
  # @param  params    Peut contenir différentes valeurs, telles que :
  #         - :tonalite   La tonalité du contexte de la note
  #         - :octave     La hauteur en octave de la note
  def initialize valeur = nil, params = nil
    case valeur.class.to_s
    when "String" then
      @note_str = valeur
      @note_int = NOTE_STR_TO_INT[valeur]
    when "Fixnum" then
      @note_int = valeur
      @note_str = str_in_context params
    else
      @note_str = nil
      @note_int = nil
    end
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