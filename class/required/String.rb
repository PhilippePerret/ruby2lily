=begin

  Extensions de la class String

  ATTENTION : CE MODULE NE DOIT ABSOLUMENT PAS ÊTRE COPIÉ DANS UN
  AUTRE PROGRAMME, IL PRÉSENTE DES ALTÉRATIONS DANGEREUSES DE LA CLASSE
  STRING ORIGINALE, NOTAMMENT AU NIVEAU DES + ET DES *.

  Traitement spécial des + et *
  ------------------------------
  Afin de faciliter l'écriture de la musique dans le score, les méthodes
  + et * ont été profondément modifiées.  
  @note : pour utiliser le * de façon ancienne, il suffit de faire :
          <string>.fois(nombre)
          Pour utiliser le + de façon ancienne, il suffit de faire :
          <string>.plus(<autre string>)
=end

class String
  
  
  # -------------------------------------------------------------------
  #   Redéfinitions propres à Ruby2Lily
  # -------------------------------------------------------------------
  

  # Additionne le string courant avec +foo+ qui peut être de n'importe
  # quelle classe (String, Motif, Note, Chord...)
  # @return   Un motif contenant les nouvelles notes
  # 
  # @note : include les opérations avec :
  #     require 'module/operations.rb'
  #     include OperationsSurNotes
  # ... ne semble pas modifier le comportement de "+", malheureusement.
  # 
  # @note : le bloc begin ... rescue ci-dessous permet de capter l'erreur
  # de mauvais argument pour un motif qui arrive fatalement dès qu'on
  # utilise un "+" dans le programme. Je les ai supprimés, mais RSpec
  # les utilise aussi pour marquer le résultat des tests. Donc, quand un
  # problème survient, on considère que c'est une utilisation normale de
  # "+" (concaténation simple) et on renvoie simplement le texte avec
  # +foo+ ajouté.
  # 
  def + foo
    begin
      self.as_motif + foo.as_motif
    rescue Exception => e
      return "#{self}#{foo}"
    end
  end
  
  # => Retourne la suite +self+ sous forme de Motif
  # 
  # @note : les italiennes est les altérations #/b sont traités par
  # la méthode LINote::to_llp
  # 
  # @note   Self peut être une suite, pas seulement une note seule
  # 
  # @note : les octaves, dans les strings, peuvent être stipulés à
  # l'aide d'apostrophes et de dièses. En sachant que ce sont des deltas
  # et pas des valeurs absolues, et ces deltas se calculent à partir de
  # c'''. Donc "a'" signifiera a-4e octave.
  def as_motif
    # On traduit en lilypond (italiennes et altérations)
    suite_llp = LINote::to_llp( self )
    exploded  = LINote::explode( suite_llp )
    data = {:notes => [], :duration => nil, :octave => nil}
    first_note_or_rest_traited = false
    exploded.each do |linote|
      unless first_note_or_rest_traited
        data[:duration] = linote.duration
        
        data[:notes]    << linote.to_s(:except => {:octave_llp => true, :duration => true})
            # @note : il ne faut pas mettre la marque d'octave lilypond
            # éventuellement enregistrée dans la LINote, car elle sera
            # considérée ci-dessous. Au début d'un motif, on évite de
            # mettre une marque d'octave (apostrophe ou virgule), il vaut
            # mieux mettre une marque d'octave juste au motif
            
        first_note_or_rest_traited = true
      else
        # Autre que la première note
        # MAIS : si les premières étaient des silences, la note courante
        # peut comporter une marque de delta d'octave. Il faut donc
        # retirer la marque d'octave tant que data[:octave] est nil
        except = { :octave_llp => data[:octave].nil? }
        data[:notes] << linote.to_s(:except => except)
      end
      # On définit l'octave s'il est défini
      # @note : pas mis sur la première note car ça peut être un silence
      unless linote.rest?
        octave = linote.octave
        data[:octave] = octave if data[:octave].nil?# && octave != 3
      end
    end 
    data[:notes] = data[:notes].join(' ')
    # On retourne le motif
    Motif::new( data )
  end
  
  
  
  # => Multiplie la note ou le groupe de notes string
  # 
  # @usage      <notes> = "<note/notes>" * <nombre>
  # 
  # @note : il y a deux résultats possibles. Si <string> est une simple
  #         note (string sans espace), alors on renvoie la note 
  #         multipliée par la valeur voulue.
  #         En revanche, si <string> est un groupe de notes, alors ce
  #         groupe est transformé en Motif avant d'être multiplié, et
  #         donc le retour sera plus complexe, du style :
  #         "\\relative c'' { a b c } \\relative c'' { a b c }"
  # @todo: String#* doit être supprimé car ajouté et traité par OperationsSurNotes
  def *( nombre )
    if self.is_lilypond?
      # Multiplication pour une suite de notes LilyPond
      Motif::new( self ) * nombre
    else
      # Multiplication conventionnelle
      self.x nombre
    end
  end
  
  # =>  Retourne la distance de la note à ut
  def dut
    @dut ||= lambda {
      LINote::NOTE_STR_TO_INT[note_with_alter]
    }.call
  end
  
  # => Retourne true si +self+ peut être un motif LilyPond
  def is_lilypond?
    # tested = self.gsub(/(#{LINote::REG_NOTE_COMPLEXE}| )/, '')
    # puts "\nSelf = '#{self}'"
    # puts "Reste = '#{tested}'"
    reste = self.gsub(/(#{LINote::REG_NOTE_COMPLEXE}| )/, '')
    unless reste == ""
      puts "\n=== EXPRESSION LILYPOND INCORRECTE ==="
      puts "= Expression : #{self}"
      puts "= Reste après filtre LINote::REG-NOTE-COMPLEXE: '#{reste}'"
      puts "= Détail :"
      self.gsub(/(#{LINote::REG_NOTE_COMPLEXE}| )/){
        puts "= capture de: '#{$&}'"
      }
    end
    reste == ""
  end 
  
  # =>  Retourne la note avec son altération
  #     Ex: si self = "<fisis8-^", retourne "fisis"
  def note_with_alter
    @note_with_alter ||= lambda {
      res = self.scan(/([a-g](eses|isis|es|is)?)/)
      return nil if res.nil? || res.first.nil?
      res.first.first
    }.call
  end
  
  # =>  Retourne la distance de la note à do, en montant ou en descendant
  #     suivant la valeur de +en_montant+
  # 
  def distance_to_do en_montant = true
    note = note_with_alter
    # return en_montant ? 12 : 0 if note == "c"
    dtd = LINote::NOTE_STR_TO_INT[note]
    dtd = 12 - dtd if en_montant
    dtd
  end
  
  
  # => Retourne la note la plus proche de self, soit la +note+ supérieure
  #    soit la note inférieure, pour l'octave donné 
  # 
  # @param    note      La note qu'il faut trouver
  # @param    octave    Octave de self. Si nil, on renvoie la note
  #                     par rapport à 3
  # 
  # @return   Un hash contenant 
  #             :note     La note, avec altérations
  #             :octave   Son octave
  #             :sup      true si la note est supérieure à self
  # 
  # 
  def closest note, octave = nil                                          # "fis d"   "a d"     "c3 fis"    "fis c"     "gis d"
    
    # Le delta d'octave de la +note+
    # -------------------------------
    delta_note = LINote::octaves_from_llp note
    delta_self = LINote::octaves_from_llp self

    # Retrait des marques d'octave des membres à étudier
    note = note.gsub(/[',]/, '')
    self_sans_delta = self.gsub(/[',]/, '')
    
    # L'octave réel, en tenant du delta d'octave du self
    octave ||= 3
    octave += delta_self
    
    # Le delta qu'il faudra ajouter à toutes les octaves
    delta_octaves = delta_note - delta_self

    # Cas piège que je n'ai pas réussi à rationnaliser :
    # Quand la première note est un b au-dessus d'un c avec une
    # altération qui fait passer le b au-dessus (ou égal) au do, 
    # comme par exemple dans :
    # "bis c", "bis ces"
    if self_sans_delta[0..0] == "b" && note[0..0] == "c"
      octave_note = octave + 1 + delta_octaves
      sup =   Note::valeur_absolue(self_sans_delta, octave) \
            <= Note::valeur_absolue( note, octave_note)
      return {:note => note, :octave => octave_note, :sup => sup}
    end
    
    # Cas simple où les deux notes sont identiques
    if self_sans_delta[0..0] == note[0..0]
      octave_note = octave + delta_octaves
      sup = Note::valeur_absolue(self_sans_delta, octave) \
            <= Note::valeur_absolue(note, octave_note)
      return {:note => note, :octave => octave_note, :sup => sup}
    end
    
    # "DUT" des deux notes
    # ---------------------
    # C'est-à-dire la distance de leur note par rapport à do sur la
    # gamme chromatique
    # dut_self = self_sans_delta.dut                                                 # fis = 6   a = 9     c3  => 0    fis => 6    8
    # dut_note = note.dut                                                 # d = 2     d = 2     fis => 6    c => 0      2
    
    # La note est-elle avant self ?
    # -----------------------------
    # Il s'agit ici d'une estimation dans l'absolu, sans tenir compte
    # ni de l'octave ni du comportement de LilyPond par rapport aux
    # notes.
    note_is_avant_self = note.dut < self_sans_delta.dut                              # OUI       OUI       NON         OUI         OUI
    
    # On calcule le dut de la deuxième note possible
    dut_other_note = note.dut + (note_is_avant_self ? 12 : -12)           # 14        14        -6          12          14
    
    # Dut de la note sous self et de la note au-dessus de self. Une de
    # ces deux notes sera choisie comme note finale.
    dut_note_up   = [note.dut, dut_other_note].max                       # 14          6          12          14
    dut_note_down = [note.dut, dut_other_note].min                       # 2           -6         0           2
    
    # Une vérification de routine
    unless dut_note_up - dut_note_down == 12
      fatal_error "Mauvaise valeur de calcul obtenu dans String#closest…"
    end
    
    # Distances des deux notes par rapport à self
    # --------------------------------------------
    dist_to_up   = dut_note_up - self_sans_delta.dut                                 # 8         6           6           6
    dist_to_down = self_sans_delta.dut - dut_note_down                               # 4         6           6           6
        
    # Le Hash de la note qui sera renvoyé
    # ------------------------------------
    # Par défaut, on met l'octave à l'octave courante
    hash_note = {:note => note, :sup => nil, :octave => octave + delta_octaves}
    
    # Est-ce qu'on monte ou est-ce qu'on descend ? 
    # ---------------------------------------------
    # Le principe est qu'on va toujours à la note la plus proche et que
    # is les deux distances sont égales, on va vers la note de la même 
    # octave.
    if dist_to_up == dist_to_down
      # L'octave reste forcément la même dans ce cas
    else
      en_montant      = dist_to_up < dist_to_down
      # Est-ce qu'on franchit une octave
      # --------------------------------
      # On le détermine en calculant la distance de self par rapport au
      # do le plus proche et en voyant si cette distance est strictement
      # supérieure à la distance à la note (pas de changement d'octave)
      dist_to_do = self_sans_delta.distance_to_do( en_montant )
      # Distance la plus courte
      shortest_dist = [dist_to_up, dist_to_down].min
      if dist_to_do <= shortest_dist
        # => Changement d'octave
        hash_note[:octave] += en_montant ? 1 : -1
      end
    end

    # Est-ce que ça monte ou ça descend ?
    # 
    self_absolue = Note::valeur_absolue(self_sans_delta, octave)
    note_absolue = Note::valeur_absolue(hash_note[:note], hash_note[:octave])
    hash_note[:sup] = note_absolue >= self_absolue
    
    # On retourne le hash de la note
    hash_note
  end
  
  # Renvoie true si le self (qui doit être une note de "a" à "g") se
  # trouve après +note+ (qui doit être seulement une note de "a" à
  # "g") dans la gamme diatonique (qui commence à "c")
  def after? note
    LINote::GAMME_DIATONIQUE.index(self) \
    > LINote::GAMME_DIATONIQUE.index(note)
  end
  
  # =>  Return le nombre de demi-tons entre +note+ (une note avec 
  #     altérations lilypond) et self (note avec altérations llp)
  # 
  # @note:  Le nombre est positif si self est au-dessus de +note+,
  #         négatif dans le cas contraire.
  def interval_with note
    LINote::NOTE_STR_TO_INT[self] - LINote::NOTE_STR_TO_INT[note]
  end
  
  # -------------------------------------------------------------------
  #   Méthodes compensatrices
  # -------------------------------------------------------------------
  
  # Pour remplacer "*" modifiée ci-dessus
  def fois nombre
    t = ""
    nombre.times.each { |i| t << self }
    t
  end
  alias :x :fois
  
  # Pour concaténer à la place de "+"
  # @usage :
  #   <string>.plus(<autre string>) => "<string><autre string>"
  def plus chaine
    "#{self}#{chaine}"
  end
  
  # Pour compenser l'utilisation normale de "+="
  def add chaine
    self << chaine.to_s
  end
  
  # -------------------------------------------------------------------
  #   Common
  # -------------------------------------------------------------------
  unless defined? PURPLE # tests
    RED     = 31
    GREEN   = 32
    BLUE    = 34
    YELLOW  = 43
    CYAN    = 36
    PURPLE  = 35
    BROWN   = 33
    GRAY    = 37
    EOC     = "\e[0m"              # Pour "End Of Color"
  end
  
  def as_blue params = nil
    print_color BLUE, params
  end
  def as_green params = nil
    print_color GREEN, params
  end
  def as_red params = nil
    print_color RED, params
  end
  def as_yellow params = nil
    print_color YELLOW, params
  end
  
  def print_color code_couleur, params = nil
    params ||= {}
    style = "0"
    style = "#{style};1" unless params[:bold].nil?
    style = "#{style};4" unless params[:underline].nil?
    style = "#{style};7" unless params[:reverse].nil?
    "\e[#{style};#{code_couleur}m#{self}#{EOC}"
  end
  
  # => Renvoie true si le string est vierge
  def blank?
    self == ""
  end
  # => True si le string est un entier
  def integer?
    self.gsub(/[0-9]/, '') == ""
  end
  
  # -------------------------------------------------------------------
  # Méthodes utiles pour classes, contrôleur <==> fichier
  # ----------------------------------------------------------------------
  def camelize # "bla_bla" => "BlaBla"
    self.split(/[^a-z0-9]/i).map{|w| w.capitalize}.join
  end
  def decamelize # "BlaBla" => "bla_bla"
    self.gsub(/^([A-Z])/){$1.downcase}.gsub(/([A-Z])/){'_' << $1}.downcase
  end

  
  #   Array et Hash
  #
  #   Méthodes pour gérer les "def-hash" et les "def-array", définitions
  #   de table array et hash sous forme de string-tableau
  # -------------------------------------------------------------------
  def to_hash to_sym = true
    hashstr_to_hash false, to_sym
  end
  def to_array to_sym = true
    hashstr_to_hash true, to_sym
  end
  def hashstr_to_hash as_array = false, to_sym = true
    tb = self.strip.gsub(/\t/, ' ').gsub(/  +/, ' ')
    hash = as_array ? [] : {}
    keys        = nil
    keys_type   = []
    nombre_cles = nil
    i_last_cle  = nil
    tb.split("\n").each do |line|
      line = line.strip
      next if line == "" || line.start_with?('#') || line.start_with?( '---' )
      dline = {}
      unless keys.nil?
        # Traitement d'une ligne de données
        line = line.split(' ')
        (0..i_last_cle).each do |ikey|
          key       = keys[ikey]
          real_val  = line[ikey]
          real_val =  if key != :id
                        real_val.nil? ? nil : real_val.vdefhash_to_real( keys_type[ikey] )
                      elsif real_val.integer?
                        real_val.to_i
                      else
                        real_val
                      end
          dline = dline.merge( key => real_val )
        end
      else
        # Définition des clés
        keys = line.split(' ').collect { |e| 
          e, type = e.split('/')
          e = e.downcase()
          keys_type << type       # Le type de la donnée, si définie
          e = e.to_sym if to_sym
          e
        }
        nombre_cles = keys.count
        i_last_cle  = nombre_cles - 1
        next
      end
      # Ajouter au hash ou à l'array
      if as_array
        hash << dline
      else
        k = to_sym ? dline[keys[0]].to_sym : dline[keys[0]]
        hash = hash.merge( k => dline)
      end
    end
    hash
  end

  # Renvoie la valeur "vraie" pour un def-hash
  # @note:  Le type de la donnée a pu être défini par cle/type en
  #         haut du tableau.
  #         Types :
  #           N   Renvoie un nombre entier
  #           S   Renvoie un string
  #           A   Renvoie un array (self doit être un str où les valeurs
  #               sont séparées par des virgules. Attention : pas 
  #               d'espace !)
  #           H   Renvoie un hash (self est évalué, donc doit être égal
  #               à quelque chose comme : ":id=>2,:titre=>'Mon titre'")
  #               Attention : pas d'espaces ! Les remplacer par des 
  #               insécables
  #               Attention : pas d'accolades non plus
  def vdefhash_to_real type = nil
    case type
    when nil  then
      case self
      when '1', 'oui', 'yes', 'y' then true
      when '0', 'non', 'no',  'n' then false
      when '-', 'null'            then nil
      else self.gsub(/_/, ' ')
      end
    when 'N'  then self.to_i
    when 'S'  then self.to_s
    when 'A'  then self.split(',').collect{ |e| e.strip.gsub(/ /,' ') }
    when 'H'  then eval("{#{self.gsub(/ /,' ')}}")
    end
  end

end