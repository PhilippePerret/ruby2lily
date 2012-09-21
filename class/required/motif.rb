# 
# CLass Motif
# 

require 'noteclass'

class Motif < NoteClass
  
  unless defined? Motif::ERRORS # quand tests
    ERRORS = {
      :notes_undefined    => "valeur :notes non définie",
      :notes_non_lilypond => "valeur `:notes' non lilypond"
    }
  end
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :notes, :octave, :duration
  
  @notes    = nil   # Le motif (String)
  @octave   = nil   # L'octave du motif (par défaut, c'est 2)
  @duration = nil   # Durée du motif (optionnel)
  
  @first_note = nil   # La première note (class Note). Calculé au besoin
                      # en utilisant <motif>.first_note
  @last_note  = nil   # La dernière note (class Note). Calculé au besoin,
                      # en utilisant <motif>.last_note
  @exploded   = nil   # Le motif "explodé", c'est-à-dire un array de 
                      # toutes les notes (class LINote) telles que
                      # explodées par LINote::explode
                      # Calculé en utilisant <motif>.exploded
  
  # --- Propriétés de modification ---
  @slured   = false   # Mis à true quand on doit poser une liaison
                      # simple sur le motif : <first>( <autres notes>)
  @legato   = false   # Mis à true quand on doit poser une sur-liaison
                      # sur le motif : <first>\( <autres notes>\)
  @triolet  = nil     # Mis à la valeur si triolet (p.e. "2/3")
  
  # --- Propriétés d'affichage ---
  @clef     = nil     # La clé à utiliser à l'affichage du motif
  
  # => Instanciation
  # 
  # @param  notes   SOIT Les notes String du motif
  #                 SOIT Un hash contenant toutes les propriétés
  #                 SOIT nil pour un motif vierge
  # @param  params  Paramètres définissant le nouveau motif.
  #         Peut être :
  #         - un string définissant les notes
  #         - un array de motifs
  #         - un hash contenant :notes et :octave pour définir
  #           précisément la hauteur du motif.
  def initialize notes = nil, params = nil
    @notes    = nil
    @octave   = 4
    @duration = nil
    @slured   = false
    @legato   = false
    @triolet  = nil
    @clef     = nil
    case notes.class.to_s
    when "Hash"   then set_with_hash notes
    when "String" then set_with_string notes
    end
    # puts "\n\n= Avant set properties : #{self.inspect}"
    set_properties params
    # puts "\n= Avant any_notes_to_llp: #{self.inspect}"
    any_notes_to_llp
    # puts "\n= Avant rationnalize_durees: #{self.inspect}"
    rationnalize_durees
    # puts "\n= Avant implode: #{self.inspect}"
    implode # pour reconstituer @notes explodé avant
  end
  
  # => Définit l'instance Motif à partir d'un Hash de données
  # 
  # @todo: Test de validité du hash transmis à la méthode
  def set_with_hash hash
    begin
      raise Liby::ERRORS[:hash_required]        if hash.class != Hash
      raise Motif::ERRORS[:notes_undefined]     unless hash.has_key?( :notes )
      raise Motif::ERRORS[:notes_non_lilypond]  unless hash[:notes].is_lilypond?
    rescue Exception => e
      fatal_error(:invalid_arguments_pour_motif, 
        :args   => hash.inspect, 
        :raison => e.message)
    end
    set_properties hash
  end
  
  # => Définir les propriétés du motif
  def set_properties hash
    return if hash.nil?
    # Valeurs qui ne doivent pas être traitées par params
    slured  = hash.delete(:slured)
    legated = hash.delete(:legato)
    set_params hash
    # Note: il faut slurer et legater après set_params, pour que les
    # notes soient définies
    self.slure  if true === slured
    self.legato if true === legated
  end

  # => Définit le Motif (notes et durée) à partir d'un string
  #
  # @param  str   Un string définissant les notes du motif.
  #               Cette suite de note peut être dans n'importe quel
  #               format, avec italiennes et altérations "#/b"
  # 
  # @note: une étude complète des notes est faite pour les décomposer
  # @TODO:  faire une recherche sur les liaisons (première et dernière
  #         notes)
  # @TODO: faire une recherche sur les dynamiques (idem)
  def set_with_string str
    return if str.to_s.blank?
    linotes = LINote::explode(str)
    prem = linotes.first
    # puts "\n\nlinotes: #{linotes.inspect}"
    # puts "Première : #{prem.inspect}"
    
    @octave = prem.octave + prem.delta
    prem.set :delta => 0
    
    @notes = LINote::implode linotes
  end
  
  # => Définit une propriété quelconque du motif
  # 
  # @param  props     Hash de paires prop-valeur
  # 
  # @note:  Cette méthode n'utilise pas `set_params`, donc aucune 
  #         transformation n'est opéré sur les valeurs (usage interne)
  # 
  def set props
    props.each { |prop, value| instance_variable_set("@#{prop}", value) }
  end
  # => Retourne la valeur de la propriété +prop+
  def get prop
    instance_variable_get("@#{prop}")
  end
  
  # Corrige les notes pour qu'elles soient au format LilyPond
  # La suite de notes fournie à l'instanciation peut être dans n'importe
  # quel format, avec italiennes et altérations "#/b". Cette méthode
  # les transforme en notes lilypond (# => is, b => es, etc.)
  def any_notes_to_llp
    return if @notes.nil?
    @notes = LINote::to_llp @notes
  end
  
  # => Rationnalise les durées
  # 
  # Cela consiste à prendre la durée de la première note, si elle
  # existe. On en profite pour vérifier aussi les notes suivantes, afin
  # de supprimer les durées similaires ("d1 c1 r1" => "d c r" avec 
  # duration mis à "1")
  # 
  # @produit    Définit éventuellement la propriété @duration du motif
  # @produit    Supprime les durées inutiles
  def rationnalize_durees
    return if @notes.nil?
    # Exploder les notes, pour voir si une durée est définie en
    # première note. Le cas échéant, la prendre et la retirer.
    fatal_error(:invalid_motif, :bad => str) if exploded.nil?
    unless exploded.first.nil? || exploded.first.duration.nil?
      @duration = exploded.first.duration
      # Tant que la durée de la note est égale, on la supprime
      exploded.each do |note|
        break if note.duration != @duration
        note.set :duration => nil
      end
    end
  end

  # => Retourne le motif (ses propriétés) sous forme de Hash
  def to_hash
    {
      :notes    => @notes,
      :duration => @duration,
      :octave   => @octave,
      :slured   => @slured,
      :legato   => @legato,
      :triolet  => @triolet,
      :clef     => @clef
    }
  end
  
  # =>  Return les notes, simples, sans durée, sans dynamique, sans
  #     relative, etc.
  def simple_notes
    @notes
  end
  
  # => Return le motif au format lilypond (MAIS sans la marque relative)
  # 
  # @param  params    Quand la méthode est appelée par `to_s', c'est un
  #                   Hash qui peut redéfinir certains paramètres
  # 
  # @note:  Due to format de retour des méthodes, on peut se retrouver
  #         avec soit une liste de Linotes soit un string
  #         Ne pas transformer, pour accélérer la méthode dans le cas
  #         où le motif est simple (sans liaison, sans dynamique, etc.)
  def to_llp params = nil
    
    duree =
    case params.class.to_s
    when "String" then params # @todo: il faudrait vérifier que ce soit une durée valide
    when "Hash"
      params[:duration] = params.delete(:duree) if params.has_key? :duree
      duree = (params[:duration] || @duration).to_s
    else 
      nil
    end
 
    llp = notes_with_duree( duree )
    llp = notes_with_liaison(llp) if @slured || @legato
    llp = notes_with_dynamique(llp) unless @crescendo.nil?
    llp = LINote::implode( llp ) if llp.class == Array
    llp = notes_with_triolet llp
    llp
  end
  
  # =>  Return le motif en string prêt à être inscrit dans la partition
  # 
  # @note : @notes, ici, est soit un string de notes, soit une liste
  #         de motifs qu'il faut traiter séparément.
  # 
  # @note : on renvoie toujours le motif entouré par des :
  #         \\relative c''.. { ... }
  #         pour que les notes soient toujours interprétées par 
  #         rapport à la hauteur de l'instrument, pas la hauteur 
  #         atteinte. De cette façon, il n'y a aucun problème pour les
  #         additions et les multiplications.
  #         SAUF si @notes est une liste de motif, dans lequel cas 
  #         chacun d'eux sera interprété à sa manière
  # 
  # @param  params    
  #         Hash pouvant contenir :
  #            :duree        La durée à mettre aux notes du motif
  #            :octave       La hauteur à donner au motif
  #            :add_octave   Le nombre d'octaves à ajouter ou retrancher
  # 
  def to_s params = nil
    return nil if @notes.nil?
    
    # Analyse des paramètres transmis
    # --------------------------------
    params ||= {}
    
    add_octave = 
    case params.class.to_s
    when "String" then 0
    when "Fixnum" then octave_from params
    else
      if params.has_key? :octave
         octave_from( params[:octave] )
       elsif params.has_key? :add_octave
         params[:add_octave]
       else 0 end
    end

    # Complet
    "#{mark_relative(ajout=add_octave)} { #{mark_clef}#{to_llp(params)} }"

  end
  
  # => Renvoie le nombre de notes du motif
  # 
  # @param  for_real    Si true, on compte vraiment le nombre de toutes
  #                     les notes. Sinon (par défaut), on considère qu'un
  #                     accord ne compte que pour une seule note.
  def count for_real = false
    return 0 if @notes.nil? || @notes.blank?
    if for_real
      @count_for_real ||= @notes.split(' ').count
    else
      @count ||= lambda {
        count     = 0
        in_accord = false
        @notes.split(' ').each do |whole_note|
          whole_note.scan(/^(<)?([a-gr])(eses|isis|es|is)?([',]*)?([^>]*)?(>)?(.*)?$/){
            tout, acc_start, note, alter, mark_delta, rien, acc_end, fin = 
              [$&, $1, $2, $3, $4, $5, $6, $7]
            if in_accord
              in_accord = ( acc_end != ">" )
            else
              count += 1
              in_accord = ( acc_start == "<" )
            end
          }
        end
        count
      }.call
    end
  end
  alias :nombre_notes :count
  
  # => Définit la clé à utiliser pour le motif
  def set_clef valeur
    if valeur.nil?
      @clef = nil
    else
      @clef = Staff::CLE_FR_TO_EN[valeur.to_s]
      fatal_error(:bad_clef, :clef => valeur) if @clef.nil?
    end
  end
  
  # => Return la marque de clef à écrire dans le motif (avant les notes)
  def mark_clef
    return "" if @clef.nil?
    return "\\clef \"#{@clef}\" "
  end
  
  # =>  Join le motif +motif2+ au motif courant (c'est-à-dire que le
  #     motif courant va changer de @notes — ça n'est pas une nouvelle
  #     instance Motif qui est créée, sauf si +params+ contient 
  #     new => :true)
  # cf. la méthode statique LINote::join pour le détail
  def join motif2, params = nil
    motif_final = LINote::join( self, motif2 )
    change_objet_ou_new_instance motif_final, params, false
  end
  
  # =>  Return la première et la dernière note (donc hors silence) du
  #     motif.
  # 
  # @usage : [premiere, derniere] = <motif>.first_et_last_note
  def first_et_last_note strict = false
    [first_note( strict ), last_note( strict )]
  end

  # => Retourne la première note du motif
  # 
  # @param  strict    Si true, c'est uniquement une note qu'on cherche,
  #                   sinon, un silence peut être retourné
  def first_note strict = false
    return nil if @notes.nil?
    instance_variable_get("@first_note#{strict ? '_strict' : ''}") \
    || lambda {
      reg = strict ? "[a-g]" : "[a-gr]"
      note = nil
      @notes.split(' ').each do |n|
        if n.match(/^<?#{reg}/) != nil
          note = n
          break
        end
      end
      instance_variable_set(
        "@first_note#{strict ? '_strict' : ''}",
        note.nil? ? nil : LINote::new(:note => note, :octave => @octave)
      )
    }.call
  end
  
  # =>  Return la toute dernière note du motif, sans tenir compte des
  #     accord (contrairement à last_note)
  # 
  # @return : la LINote de la toute dernière note du motif
  # 
  # @param  strict    Si true, ne renvoie qu'une note, pas un silence
  # 
  def real_last_note strict = false
    return nil if @notes.nil?
    get("real_last_note#{strict ? '_strict' : ''}") || lambda {
      ln_found = nil
      exploded.reverse.each do |ln|
        ln_found = ln and break unless strict && ln.rest?
      end
      set "real_last_note#{strict ? '_strict' : ''}" => ln_found
      return ln_found
    }.call
  end
  # =>  Return la dernière note du motif en objet
  #     LINote
  #     ATTENTION : il ne s'agit pas de la toute dernière note du motif,
  #     mais de la dernière note qui servira de référence pour le delta
  #     d'octave en cas de liaison (dans un accord, seule la première
  #     note importe). Pour la "vraie" toute dernière note du motif,
  #     utiliser la méthode 'real_last_note' ci-dessus
  # 
  # @note: la difficulté par rapport à first_note est qu'il faut calculer
  # ici, suivant la suite de notes, la hauteur réelle de la dernière :
  # Car dans :
  #   "c c"   La 1ère et la dernière sont à la même octave
  # tandis que dans :
  #   "c e g c" La dernière ("c") est une octave au-dessus de la 1ère
  # et pire encore :
  #   "c e g <c e g> c" : on pourrait croire que le dernier do est
  # deux octaves plus haut que le premier, mais comme il y a un accord,
  # c'est le do de l'accord qui est pris en référence pour connaitre la
  # position du dernier.
  # 
  # @note: on en profite pour définir aussi le nombre de notes réelles
  # et relative (accord => 1 seule note) => @count / @count_for_real
  # NON : car les silences ne sont pas pris en compte ici
  # 
  def last_note strict = false
    return nil if @notes.nil?
    instance_variable_get("@last_note#{strict ? '_strict' : ''}") \
    || lambda {
      # Pour le comptage des notes (sauf si strict et true)
      unless strict
        @count_for_real = 0
        @count          = 0
      end
      # Expression régulière à utiliser
      ex = strict ? "[a-g]" : "[a-gr]"
      regexp = /^(<)?(#{ex})(eses|isis|es|is)?([',]*)?([^>]*)?(>)?(.*)?$/
      # On ne conserve que les notes, les altérations et les marques d'octaves
      liste_notes = []
      # Pour savoir si on se trouve dans un accord
      # Tant qu'on est dans un accord, seule la première note importe
      in_accord = false
      # La note précédente
      # On garde sa note (avec altération) et son octave pour savoir où
      # se trouver la note suivante.
      h_previous = nil
      # Le hash qui contiendra les données de la dernière note
      h_current = nil
      @notes.split(' ').each do |whole_note|
        @count_for_real += 1 unless strict
        whole_note.scan( regexp ){
          tout, acc_start, note, alter, mark_delta, rien, acc_end, fin = 
            [$&, $1, $2, $3, $4, $5, $6, $7]
          delta = LINote::delta_from_markdelta(mark_delta)
          if in_accord
            in_accord = ( acc_end != ">" )
            next # dans un accord, on ne prend rien
          else
            # C'est une note qu'on doit étudier
            @count += 1 unless strict
            unless h_previous.nil?
              result = note.au_dessus_de?( h_previous[:note], franchissement = true )
              au_dessus     = (result & 1) > 0
              new_octave    = (result & 2) > 0
              add_octave    = new_octave ? (au_dessus ? 1 : -1) : 0
              # L'octave de la note sera :
              #   - l'octave courant (note précédente)
              #   + le changement d'octave s'il y en a un
              #   + le delta d'octave s'il y en a un
              octave = h_previous[:octave] + add_octave + delta
            
              # # = débug =
              # puts "* note: #{note}#{alter}#{mark_delta}"
              # puts "*       Au-dessus de #{h_previous[:note]} ? #{au_dessus ? 'oui' : 'NON'}"
              # puts "*       Nouvelle octave ? #{new_octave ? 'oui' : 'NON'}"
              # puts "*       Ajout d'octave de positionnement : #{add_octave}"
              # puts "*       Ajout d'octave de delta : #{delta}"
              # puts "*       => octave final: #{octave}"
              # # = /débug =
            
              # On mémorise cette note
              h_current = {:note => note, :octave => octave, :alter => alter}
            else
              # octave suivant delta
              # @note: normalement, la première note d'un motif n'a pas de
              # delta, mais on ne sait jamais
              # @todo: à l'avenir, il faudrait prévenir le fait de mettre
              # un delta sur la première note, on le transformant 
              # automatiquement en octave.
              octave = (@octave || 4) + delta
            end
            h_previous = {
              :note => note, 
              :alter => alter, 
              :delta => delta, 
              :octave => octave
              }
            # Est-ce qu'on rentre dans un accord ?
            in_accord = ( acc_start == "<" )
          end
        }
      end
    
      octave_courant  = @octave || 4
    
      # S'il n'y a qu'une note (ou qu'un accord), on prend la première,
      # (qui peut être nil en cas de recherche strict — pas de silence —
      # sinon, on fait de la dernière note trouvée une linote
      instance_variable_set(
        "@last_note#{strict ? '_strict' : ''}", 
        h_current.nil? ? first_note(strict) : LINote::new( h_current )
        )
    }.call
    
  end
  
  # => Return (et définit) les notes du motif en array explodé
  # Cf. LINote::explode
  def exploded
    return nil if @notes.nil?
    @exploded ||= LINote::explode self
  end
  alias :explode :exploded

  # => Recompose les notes à partir de leur explosion
  # 
  # @explication: à l'instanciation, les @notes sont explodées en leurs
  # linote afin de faire certains traitement (durée prise de la première
  # note, octave défini par delta de première note, etc.). On termine
  # la procédure d'instanciation par cette méthode pour reconstituer
  # @notes.
  # 
  def implode
    return nil if @notes.nil? || exploded.nil?
    @notes = LINote::implode exploded
  end
  
  # => Méthode de commodité
  def as_motif
    self
  end
  
  # =>  Inscrit la durée +duree+ pour le motif
  # 
  # @param  duree   La durée à appliquer aux notes (la première
  #                 seulement, en général)
  #                 Si non fourni, prends la valeur de la propriété
  #                 @duration.
  # 
  # @return   La liste des LINotes du motif (puisque la méthode 
  #           `exploded' est utilisée)
  # 
  def notes_with_duree duree = nil
    # @todo: vérifier que la durée soit valide
    duree ||= @duration
    unless exploded.first.pre =~ /</
      exploded.first.set( :duree => duree )
    else
      # La première note fait partie d'un accord, on cherche la
      # dernière note de l'accord pour lui appliquer la durée
      exploded.each do |ln|
        ln.set( :duree_post => duree ) and break if ln.post =~ />/
      end
    end
    exploded
  end
  
  # =>  Retourne les @notes du motif (ou les +notes+ passés en 
  #     paramètres) avec la marque de slur ou de legato
  def notes_with_liaison notes = nil
    # puts "--> notes_with_liaison"
    notes ||= @notes
    return notes unless @slured || @legato
    markin  = @slured ? '(' : '\('
    markout = @slured ? ')' : '\)'
    LINote::post_first_and_last_note notes, markin, markout
  end
  
  # => Retourne le motif agrémenté de sa dynamique (if any)
  # 
  # @rappel:  Une dynamique est définie si @crescendo n'est pas 
  #           nil. Si non nil, elle contient :
  #             :start_dyna   Éventuellement la dynamique de départ
  #             :start        Le signe \< ou \> indiquant le sens
  #             :end          Soit «\!» soit «\fff»
  # 
  # @return   La liste de LINotes agrémentées des marques de dynamique
  #           (dans leur propriété :post et :pre pour la première si
  #            une dynamique de départ est nécessaire)
  # 
  def notes_with_dynamique notes = nil
    notes ||= @notes
    return notes if @crescendo.nil?
    start_dyna  = @crescendo[:start_dyna]
    markin      = @crescendo[:start]
    markout     = @crescendo[:end]
    markout     = " #{markout}" unless markout == '\!'
    ary_lns = LINote::post_first_and_last_note notes, markin, markout
      # @rappel: le signe est ajouté APRÈS le @post déjà défini (if any)
    unless start_dyna.nil?
      ary_lns = LINote::pre_first_note(ary_lns, "#{start_dyna} ") 
    end
      # @rappel: le signe est ajouté AVANT le @pre déjà défini (if any)
    ary_lns
  end
  
  def notes_with_triolet notes = nil
    notes ||= @notes
    return notes if @triolet.nil?
    "\\times #{@triolet} { #{notes} }"
  end
  
  
  # =>  @return la différence d'octave positive ou négative de 
  #     l'octave du motif avec +oct+.
  #     Correspond au nombre d'octaves qu'il faut ajouter à l'octave
  #     du motif pour atteindre la valeur +oct+ (ajout en négatif ou
  #     en positif)
  def octave_from oct
    oct - octave
  end
  
  # => Retourne le '\relative c..' du motif
  # @param  ajout   Le nombre d'octave à ajouter ou retrancher au motif
  # 
  # @return le texte '\relative c..'
  def mark_relative ajout = 0
    Score::mark_relative( (@octave || 4) + (ajout || 0) )
  end
    
  # -------------------------------------------------------------------
  #   Méthodes de transformation du motif tonal/modal
  # -------------------------------------------------------------------

  # => Retourne le motif baissé du nombre de +demitons+
  # @todo: plus tard, pourra modifier par degré, en restant dans la
  # gamme
  # 
  # @param  demitons    Nombre de demi-tons dont il faut monter (si
  #                     positif) ou baisser (si négatif) le motif
  #                     courant.
  # @param  params      Hash des paramètres transmis (cf. ci-dessous) ou
  #                     nil.
  # 
  # +params+ peut contenir :
  #   :new => false     Ne crée pas de nouvelle instance, modifie
  #                     le motif courant.
  #   :octave => xx     Spécifie l'octave du motif.
  # 
  # @return une NOUVELLE instance de motif, sauf si +params+ contient
  # :new => false
  def moins demitons, params = nil
    # La question qui se pose ici est : 
    # Est-ce vraiment le bon moyen de repérer les notes dans un
    # motif ?
    new_motif = @notes.gsub(/\b([a-g](is|es)?(is|es)?)/){
      note = $1
      # debug "note dans moins : #{note}"
      LINote::new(note).moins(demitons, :tonalite => SCORE::key)
    }
    change_objet_ou_new_instance new_motif, params, true
  end
  # => Retourne le motif monté du nombre de +demitons+
  # @todo: plus tard, pourra modifier par degré, en restant dans la
  # gamme
  # 
  # @return une NOUVELLE instance de motif
  def plus demitons, params = nil
    new_motif = @notes.gsub(/\b([a-g](is|es)?(is|es)?)/){
      note = $1
      # debug "note dans plus : #{note}"
      LINote::new(note).plus(demitons, :tonalite => SCORE::key)
    }
    change_objet_ou_new_instance new_motif, params, true
  end
  
  
  # => Applique une liaison au motif courant
  # 
  # @return   Le motif courant
  # 
  # @note: si le motif contient déjà une marque de slured, on 
  # utilise le legato. S'il utilise déjà le sur-legato, on produit une
  # erreur
  def slure
    if @legato === true
      fatal_error(:motif_legato_cant_be_slured)
    elsif legato?
      fatal_error(:motif_cant_be_surslured, :motif => @notes)
    elsif slured?
      if legato?
        fatal_error(:motif_cant_be_surslured, :motif => @notes)
      else
        @legato = true
      end
    else
      @slured = true
    end
    self
  end
  
  # => Renvoie un nouveau motif slured (sauf si params[:new] = false)
  def slured params = nil
    if params != nil && params[:new] == false
      self.slure
    else
      self.clone.slure
    end
  end
  alias :lie :slured
  
  # =>  Retourne le motif en legato (...\( ...\))
  # 
  # @return L'OBJET LUI-MÊME (ou la nouvelle instance si :new => true)
  def legato params = nil
    if @notes.match(/\\[\(\)]/) != nil
      fatal_error(:motif_cant_be_surslured, :motif => @notes)
    end
    if params != nil && params[:new] === true
      inst = self.clone
      inst.instance_variable_set("@legato", true)
      inst
    else
      @legato = true
      self
    end
  end
  
  # =>  Return true si le motif est slured (soit par sa propriété
  #     @slured, soit par sa suite de notes)
  def slured?
    @slured || @notes.match(/[^\\][\(\)]/) != nil
  end
  # =>  Return true si le motif est legato (soit par sa propriété 
  #     @legato soit par sa suite de notes)
  def legato?
    @legato || @notes.match(/\\[\(\)]/) != nil
  end
  
  # => Transforme le motif en triolet (ou plus)
  # 
  # @param  natural    
  #         La division naturelle du temps, 2 par défaut, c'est-à-dire 
  #         en binaire, ou le triolet complet : "2/3" par exemple.
  # @param  nb_notes        
  #         Nombre de notes dans le nouveau motif. Si nil et que 
  #         natural n'est pas un String, on met 3
  def triolet natural = nil, nb_notes = nil
    natural ||= 2
    val = "#{natural}"
    val << "/#{nb_notes || '3'}" unless natural.class == String
    change_objet_ou_new_instance @notes, {:triolet => val}, false
  end
  alias :triplet :triolet
  
  # Applique le triolet voulu (méthode conventionnelle, qui sera aussi
  # utilisée en cas de définition dans les paramètres)
  # 
  # @param  valeur    
  #         La valeur de triolet LLP à appliquer. Si true, on met "2/3"
  #         qui est la définition naturelle du triolet. Sinon, c'est la
  #         valeur String à mettre après \times, donc ça doit être une
  #         valeur LilyPond correcte et correspondant au nombre de notes
  #         Lève une erreur fatale en cas d'erreur.
  def set_triolet valeur = nil
    begin
      if valeur === true || valeur == "2/3"
        valeur    = "2/3"
        nb_notes  = 3
      else
        natural, nb_notes = valeur.split("/")
        raise 'bad_value_for_triolet' if nb_notes.nil?
        # @todo: il faut ajouter ici les autres valeurs pour les divisions exceptionnelles
      end
      raise 'bad_nombre_notes_for_triolet' if nb_notes.to_i != count
    rescue Exception => e
      fatal_error(e.message, :bad => valeur, :notes => @notes)
    end unless valeur.nil?
    
    @triolet = valeur
  end
  alias :set_triplet :set_triolet
  
  # Utiliser par `set_params' quand le motif est défini avec
  # :crescendo => true
  # 
  # @todo: pouvoir utiliser :crescendo => {:start}
  def set_crescendo pms
    start_dyna  = nil
    fin_dyna    = '\!'
    if pms === true
      for_crescendo = true
    elsif pms === false
      for_crescendo = false
    elsif pms.class == Hash
      start_dyna    = mark_dyna(pms[:start]) if pms.has_key?(:start)
      fin_dyna      = mark_dyna(pms[:end])   if pms.has_key?(:end)
      for_crescendo = pms[:for_crescendo]
    end
    @crescendo = {
      :start_dyna => start_dyna,
      :start      => for_crescendo ? '\<' : '\>',
      :end        => fin_dyna
      }
  end
  def set_decrescendo valeur
    valeur = false if valeur === true # si si
    set_crescendo valeur
  end
  # => Applique un crescendo/decrescendo au motif
  # 
  # @param  params  Options:
  #                   :start    La dynamique de départ (if any)
  #                   :end      La dynamique de fin (if any)
  #                   :new      Crée une nouvelle instance si true, sinon
  #                             modifie l'objet courant (false par défaut)
  # 
  # @return   Le motif courant ou le nouveau motif si :new => true
  # 
  def crescendo   params = nil; cresc_or_decresc params, true   end
  def decrescendo params = nil; cresc_or_decresc params, false  end
  def cresc_or_decresc pms, for_crescendo
    pms ||= {}
    new_instance = pms.delete( :new ) === true
    pms = pms.merge( :for_crescendo => for_crescendo )
    pms = { :crescendo => pms }
    pms = pms.merge :new => new_instance
    change_objet_ou_new_instance @notes, pms, false
  end
  def mark_dyna dyna
    return dyna if dyna.start_with? "\\"
    "\\#{dyna}"
  end
  
  # =>  Méthode appelée à la fin de toutes les méthodes, créant une
  #     nouvelle instance de Motif ou modifiant l'instance courante
  #     en fonction de la valeur +new_instance+
  # -------------------------------------------------------------------
  # @param  new_motif   Le nouveau motif obtenu par la méthode
  # @param  params      Les paramètres envoyés à la méthode
  # @param  new_defaut  La valeur de :new par défaut
  # 
  # @return L'instance créée ou l'instance courante
  # -------------------------------------------------------------------
  def change_objet_ou_new_instance new_motif, params, new_defaut
    params = set_new_if_not_defined( params, new_defaut )

    make_new_motif = params.delete(:new) === true
    
    # Définir les valeurs
    # -------------------------
    params[:octave] ||= @octave

    # Instance nouvelle ou courante modifiée
    if make_new_motif
      params[:notes]    = new_motif
      params[:triolet]  = @triolet
      # On prend tous les paramètres du motif courant pour faire
      # une nouvelle instance
      # NON : SURTOUT PAS, CAR POUR UN MOTIF AVEC LEGATO, SON ADDITION
      # AVEC AUTRE CHOSE ALLONGERAIT SON LEGATO
      # params = to_hash.merge params
      Motif::new params
    else
      @notes  = new_motif
      set_params params
      self
    end
  end
  
  # => Définit la valeur de params[:new] si non défini
  def set_new_if_not_defined params, val_def
    params ||= {}
    return params if params.has_key? :new
    params[:new] = val_def
    params
  end
  
  
end