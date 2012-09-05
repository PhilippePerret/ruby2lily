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
  
  # =>  Join la suite de note +motif1+ à la suite +motif2+
  #     en retournant un string prenant en compte les octaves
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

    # Contrôle de la validité des arguments (fatal)
    cl1, cl2 = [motif1.class, motif2.class]
    fatal_error(:bad_type_for_args, :good => "Motif", :bad => cl1.to_s) \
      unless cl1 == Motif
    fatal_error(:bad_type_for_args, :good => "Motif", :bad => cl2.to_s) \
      unless cl2 == Motif
    
    motif1_last   = motif1.last_note
    motif2_first  = motif2.first_note
    valeur_abs_last_motif1  = 
      Note::valeur_absolue(motif1_last, motif1.octave)
    valeur_abs_first_motif2 = 
      Note::valeur_absolue(motif2_first, motif2.octave)

    # Intervalle entre les deux notes
    intervalle = valeur_abs_first_motif2 - valeur_abs_last_motif1
    
  #   # = débug =
  #   puts <<-EOC
  # 
  # MOTIF 1           : #{motif1.motif}
  # Last de motif 1   : #{motif1_last}
  #     Octave        : #{motif1.octave}
  #     Valeur absolue: #{valeur_abs_last_motif1}
  # MOTIF 2           : #{motif2.motif}
  # First de motif 2  : #{motif2_first}
  #     Octave        : #{motif2.octave}
  #     Valeur absolue: #{valeur_abs_first_motif2}
  # 
  # Intervalle        : #{intervalle}
  #   EOC
  #   # = /débug =
   
   
    # Rappel : le changement d'octave est nécessaire dès que l'intervale
    # entre les notes dépassent la quarte.
    #  c f# => le f# est au-dessus (intervale f# - c = 6)
    #  c g  => le g est au dessous (intervale g  - c = 7)
    # 
    #   Étudier :
    #     d f a (3) - d a f (3)     => d f a d, a f
    #     d f a (3) - d a f (4)     => d f a d  a f
    #     d f a (3) - d a f (5)     => d f a d' a f
    #     d f a (3) - d a f (2)     => d f a d,, a f
    # 
    #     Intervalle entre a3 et d3 = -7
    #     Intervalle entre a3 et d4 = 5
    #     Intervalle entre a3 et d5 = 5 + 12 = 17
    #     Intervalle entre a3 et d2 = - (7 + 12)
    # 
    #   On en déduit que : 
    #       - intervalle entre 0 et 6   => on ne fait rien
    #       - intervalle entre 0 et -6  => on ne fait rien
    #       - intervalle > 6  => il faut forcément ajouter des « ' »
    #         On retire 6 (intervalle - 6) et on divise par 12 et on
    #         ajoute 1 pour savoir le nombre d'apostrophes à ajouter.
    #       - intervalle < -6 => il faut forcément ajouter des « , »
    #         On prend la valeur absolue de l'intervalle, on retire
    #         6, et le reste divisé par 12 + 1 donne le nombre de virgules
    
    if intervalle.between?(-6, 6)
      # Rien à faire, la note se placera naturellement
      
      # Le motif final retourné
      "#{motif1.motif} #{motif2.motif}"
      
    else
      # Il faut ajouter des ' ou des ,

      # La marque d'octave qui sera utilisée (au-dessus ou en dessous)
      mark = intervalle > 0 ? "'" : ","

      # On retire 6
      add_octaves = intervalle.abs - 6
      # On divise par 12
      add_octaves = add_octaves / 12
      # On ajoute 1
      add_octaves += 1
      # => le nombre de signes à ajouter à la 2e note pour l'atteindre
    
      # Modification de la première note du motif 2
      new_first = "#{motif2_first}#{mark.x(add_octaves)}"
      # (on utilise `sub', qui modifiera forcément la première note)
      new_motif2 = motif2.motif.sub(/#{motif2_first}/, new_first)

  #     # = débug =
  #     puts <<-EOC
  # 
  # mark              : #{mark}
  # Octaves ajoutées  : #{add_octaves}
  # Nouvelle première : #{new_first}
  # Nouveau motif     : #{new_motif2}
  #     EOC
  #     # = /débug =

      # Le motif final retourné
      "#{motif1.motif} #{new_motif2}"
    end
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