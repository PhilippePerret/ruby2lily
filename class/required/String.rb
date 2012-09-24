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
      # Ex-commenter le passage ci-dessous pour voir le message d'erreur
      # en cas de problème d'additions de notes string
      # puts "\nERREUR dans « + » de string : #{e.message} "
      return "#{self}#{foo}"
    end
  end
  
  # => Retourne la suite +self+ sous forme de Motif
  # 
  # @note   +self+ peut être une suite, pas seulement une note seule
  # @note   Les italiennes et altérations "normales" seront transformées
  # 
  def as_motif
    motif = Motif::new self
    # puts "\nSTRING '#{self}' TRANSFORMÉ EN MOTIF : #{motif.inspect}"
    motif
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
      self.as_motif * nombre
    else
      # Multiplication conventionnelle
      self.x nombre
    end
  end

  # Redéfinition de la méthode [] mais avec possibilité d'appeler
  # l'ancienne
  old_crochets = instance_method(:[])
  define_method(:[]) do |*params|
    # En cas de Range, on sait que c'est l'ancienne méthode qu'il faut
    # utiliser (la méthode [] ruby2lily ne supporte pas les Range)
    if params.first.class != Range && self.is_lilypond?
      begin
        motif = self.as_motif
      rescue Exception => e
        # On continuera ci-dessous
      else
        return motif.send('[]', *params )
      end
    end
    # Dans tous les autres cas, on appelle la méthode normale
    old_crochets.bind(self).call(*params)
  end  
  
  # =>  Return un hash contenant :note, :alter et :delta de la note OU
  #     PAR DÉFAUT le LINote de la note
  # 
  # @param  self        Une note Lilipond valide et unique avec
  #                     son delta d'octave, p.e. "ees''"
  # @param  as_linote   Si true (par défaut), renvoie un objet LINote,
  #                     sinon renvoie un hash contenant seulement :note
  #                     :alter et :delta
  # 
  # @return   La LINote de la note ou un hash contenant :note (simple),
  #           :alter et :delta
  # 
  # @todo:  il faudrait ne pas être obligé de passer par une linote car
  #         cette méthode peut être appelée de façon intensive.
  #         Donc: n'instancier une linote que lorsque c'est stipulé.
  # 
  def explode as_linote = true
    linote = LINote::llp_to_linote self
    return linote if as_linote
    { 
      :note => linote.note, 
      :alter => linote.alter, 
      :delta => linote.delta
    }
  end
  # Cf. :explode ci-dessus
  def to_linote
    explode true
  end
  
  # => Retourne la +note+ avec son altération dans la tonalité +key+
  def with_alter_in_key key
    hash = LINote::alterations_notes_in_key( key )
    hash[self]
  end
  
  # => Retourne true si le string +self+ est un silence
  # 
  # @todo: pour le moment, la vérification est simpliciste (only la 1ere
  # lettre) mais on pourrait envisager à l'avenir de la développer si
  # nécessaire.
  def rest?
    self[0..0] == "r"
  end
  
  # => Retourne true si +self+ peut être un motif LilyPond
  def is_lilypond?
    # tested = self.gsub(/(#{LINote::REG_NOTE_COMPLEXE}| )/, '')
    # puts "\nSelf = '#{self}'"
    # puts "Reste = '#{tested}'"
    reste = self.gsub(/(#{LINote::REG_NOTE_COMPLEXE}| )/, '')
    # unless reste == ""
    #   puts "\n=== EXPRESSION LILYPOND INCORRECTE ==="
    #   puts "= Expression : #{self}"
    #   puts "= Reste après filtre LINote::REG-NOTE-COMPLEXE: '#{reste}'"
    #   puts "= Détail :"
    #   self.gsub(/(#{LINote::REG_NOTE_COMPLEXE}| )/){
    #     puts "= capture de: '#{$&}'"
    #   }
    # end
    reste == ""
  end 
  
  # =>  Retourne la note avec son altération
  #     Ex: si self = "<fisis8-^", retourne "fisis"
  # 
  # @note: explode lèvera une erreur fatale si self n'est pas une
  # note lilypond correcte.
  # 
  def note_with_alter
    fatal_error(:not_note_llp, :note => self
      ) if self.match(/^<?[a-g]/).nil?
    @note_with_alter ||= lambda {
      self.explode.with_alter
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
  # @param    note      La note qu'il faut trouver (String)
  # @param    octave    Octave de self. Si nil, on renvoie la note
  #                     par rapport à 3
  # 
  # @return   Une linote de la note la plus proche trouvée
  # 
  # @todo: cette méthode n'est-elle pas obsolète ?
  # 
  def closest note, octave = nil
    
    octave_self = octave || 4
    octave_self += LINote::delta_from_markdelta self

    # ln_self   = LINote::new self, :octave => octave
    
    res = note.au_dessus_de? self, franchissement=true
    note_est_plus_haut = (res & 1) > 0
    octave_franchie    = (res & 2) > 0
    
    # Octave ajouté en cas de franchissement
    ajout_franchissement =  if octave_franchie
                              note_est_plus_haut ? 1 : -1
                            else 
                              0
                            end
      
    # La LINote qui sera renvoyée (à partir de +note+ — calculé ici pour
    # obtenir son delta d'octave)
    ln_note = note.explode
    
    # Octave final, en tenant compte du delta d'octave de la note, 
    # et du franchissement ou non de l'octave
    octave_note = octave_self + ln_note.delta + ajout_franchissement
    
    # On régle pour terminer l'octave de la LINote à retourner
    ln_note.set :octave => octave_note
    
    # # = débug =
    # # Résumé des opérations
    # puts "\n\n=== String#closest ==="
    # puts "= self: #{self} (octave #{octave_self})"
    # puts "= note: #{note}"
    # puts "= Donc : on cherche la note #{note} la + proche de #{self}"
    # puts "= #{note} plus haut que #{self} ? #{note_est_plus_haut ? 'oui' : 'NON'}"
    # puts "= Franchissement d'octave ? #{octave_franchie ? 'oui' : 'NON'}"
    # puts "= (car résultat de #{note}.au_dessus_de?(#{self}) : #{res})"
    # puts "= Ajout pour le franchissement d'octave : #{ajout_franchissement}"
    # puts "= Octave final de la note la plus proche : #{octave_note}"
    # puts "= (calculé par l'addition de :"
    # puts "=   L'octave de self : #{octave_self}"
    # puts "=   Le delta de note : #{ln_note.delta}"
    # puts "=   L'ajout de franchissement d'octave : #{ajout_franchissement}"
    # puts "================================================"
    # # = / débug =

    return ln_note

  end
  
  # =>  Retourne l'index diatonique de +self+
  # 
  # @param  self    Une note, simple ou non
  # @return   L'index dans la gamme diatonique, sans tenir compte
  #           ni des altérations ni des delta
  def index_diat
    LINote::GAMME_DIATONIQUE.index self[0..0]
  end
  # =>  Retourne true si la note +self+ se trouve au-dessus de la note
  #     +note+ dans un motif LilyPond
  # 
  # @warning :  la réponse se fait par rapport à la *position de la note
  #             sur la portée*, pas sa hauteur absolue. Ainsi, elle 
  #             renvoie true pour "ces".au_dessus_de?("bis") alors que 
  #             "bis" est en réalité plus haut. Pour tester la hauteur,
  #             utiliser :plus_haute_que?/:higher_than
  # 
  # @param  self    Une note LLP, avec ou sans delta d'octave
  # @param  note    Idem
  # @param  with_franchissement
  #                 Si mis à true (false par défaut), la méthode 
  #                 retourne un nombre dont on teste les bits pour
  #                 savoir si l'octave est franchi lors du passage entre
  #                 self et la note.
  #                 BIT 1   Au-dessus si 1, en dessous si 0
  #                 BIT 2   Franchissement d'octave si 1, pas si 0
  #                 Donc :
  #                 0   =>  +self+ n'est pas au-dessus de +note+
  #                         et pas de franchissement d'octave
  #                 1   =>  +self+ est au-dessus de +note+ mais il n'y a
  #                         pas franchissement d'octave
  #                 2   =>  +self+ est EN DESSOUS de +note+ mais
  #                         il y a franchissement d'octave
  #                 3   =>  +self+ est au-dessus et il y a franchissement
  #                 On peut faire aussi :
  #                 au_dessus       = (res & 1) > 0
  #                 franchissement  = (res & 2) > 0
  # 
  # @return true/false
  # 
  # Est-ce qu'on franchit une octave ?
  # On le sait quand l'intervalle est négatif (non pas seulement)
  # "c d" "c e" ""
  #  0 1
  # # Intervalles négatifs sans franchissement
  # "d c" "f d" "f c" ""
  #  1 0   3 1   3 0
  # # Franchissement
  # "b c", "b d" "d a" "d b"
  #  6 1    6 1   1 5   1 6
  #  
  #  # Essai avec :
  #  # L'octave est franchit quand :
  #  note plus haute ET (note - self) < 0
  #  note moins haut ET (note - self) > 0
  def au_dessus_de? note, with_franchissement = false
    
    return (with_franchissement ? 0 : false) if self.rest? || note.rest?
    
    # Index diatonique des deux notes
    index_note = note.index_diat
    fatal_error(:not_a_note, 
                :bad => note,
                :method => "String#au_dessus_de?") if index_note.nil?
    index_self = self.index_diat
    fatal_error(:not_a_note, 
                :bad => self, 
                :method => "String#au_dessus_de?") if index_self.nil?
    diff_index = index_note - index_self
    case diff_index
    when 0    then 
      au_dessus = false
      franchiss = false
    when 1..3, -6..-4 then 
      au_dessus = false
      franchiss = diff_index < 0
    when 4..6, -3..-1 then true
      au_dessus = true
      franchiss = diff_index > 0
    end
    return au_dessus unless with_franchissement
    # On doit retourner un nombre où le premier bit correspond à
    # au-dessus/en dessous et le second à l'indication du franchissement
    # de l'octave ou non
    twobits  = au_dessus ? 1 : 0
    twobits += franchiss ? 2 : 0
    twobits
  end
  alias :above? :au_dessus_de?
  
  # =>  Return la valeur absolue de +self+, c'est-à-dire son numéro MIDI
  #     par rapport à :
  #       - sa note
  #       - ses altérations
  #       - son delta d'octave
  # 
  # @param  self      La note, avec altération et delta
  # 
  # @return   Le nombre, entre 21 (A0) et 108 (C8)
  # 
  def abs
    self.explode( as_linote = true ).abs
  end
  # =>  Return true si +self+ est au-dessus, en tant que son, de +note+
  # 
  # @warning :  La réponse se fait en fonction de la hauteur absolu du
  #             *son*, pas de la note sur la portée.
  # 
  # @param  self  Une note string, avec altération et delta d'octave
  # @param  note  Une note, avec altération et delta d'octave
  # 
  def plus_haute_que? note
    self.abs > note.abs
  end
  alias :higher_than? :plus_haute_que?
  
  # Renvoie true si le self (qui doit être une note de "a" à "g") se
  # trouve après +note+ (qui doit être seulement une note de "a" à
  # "g") dans la gamme diatonique (qui commence à "c")
  def after? note
    self.index_diat > note.index_diat
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