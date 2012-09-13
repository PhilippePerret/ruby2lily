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
    @octave   = 3
    @duration = nil
    @slured   = false
    @legato   = false
    case notes.class.to_s
    when "Hash"   then set_with_hash notes
    when "String" then set_with_string notes
    end
    
    set_properties params
    
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
  #               Peut-être dans n'importe quel format, avec italiennes
  #               et altérations "#/b"
  def set_with_string str
    # puts "\n\n--> set_with_string('#{str}')"
    # Corriger les italiennes et altérations
    notes = LINote::to_llp str
    # puts "Notes après LINote::to_llp : #{notes}"
    # Exploder les notes, pour voir si une durée est définie en
    # première note. Le cas échéant, la prendre
    notes = LINote::explode notes
    # puts "Notes retournés de LINote::explode : #{notes.inspect}"
    fatal_error(:invalid_motif, :bad => str) if notes.nil?
    unless notes.first.nil? || notes.first.duration.nil?
      @duration = notes.first.duration
      notes.first.set(:duration => nil)
    end
    @notes = LINote::implode notes
    # puts "@notes à la fin du processus : #{@notes}"
  end
  # =>  Return le motif en string avec l'ajout de la durée +duree+ si 
  #     elle est spécifiée
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
    # Et principalement la durée
    params ||= {}
    if [Fixnum, String].include? params.class
      params = {:duration => params}
    elsif params.has_key? :duree
      params = params.merge(:duration => params.delete(:duree))
    elsif !params.has_key? :duration
      params = params.merge(:duration => @duration)
    end
    
    duree = params[:duration]
    
    # Définition de l'octave du motif
    # --------------------------------
    octaves_to_add =  if params.has_key? :octave
                        octave_from( params[:octave] )
                      elsif params.has_key? :add_octave
                        params[:add_octave]
                      else 0 end
    

    # Mark relative (\\relative c...) pour le motif
    # ----------------------------------------------
    mk_relative = mark_relative octaves_to_add

    # Changement des durées si nécessaire
    notes_str = if duree.nil? then @notes 
                else notes_with_duree(duree) end 

    # Liaisons ?
    notes_str = notes_with_liaison notes_str
    
    # Finalisation
    return "#{mk_relative} { #{mark_clef}#{notes_str} }"

  end
  
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
  
  # => Return le motif au format lilypond (MAIS sans la marque d'octave)
  def to_llp
    suite_llp = notes_with_duree
    suite_llp = notes_with_liaison(suite_llp) if @slured || @legato
    suite_llp
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
  def first_et_last_note
    [first_note, last_note]
  end

  # => Retourne la première note (donc pas un silence) du motif
  def first_note
    return nil if @notes.nil?
    @first_note ||= lambda {
      note = @notes.note_with_alter # retourne seulement la première
      fatal_error(:unable_to_find_first_note_motif, :notes => @notes ) \
        if note.nil?
      LINote::new :note => note, :octave => @octave
    }.call
  end
  # =>  Return la dernière note (donc pas un silence) du motif en objet
  #     LINote
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
  def last_note
    return nil if @notes.nil?
    @last_note ||= lambda {
      
    
    # NOUVELLE MÉTHODE
    # On ne conserve que les notes, les altérations et les marques d'octaves
    liste_notes = []
    " #{@notes}".gsub(/ <?(([a-g])(eses|isis|es|is)?([',]*))/){
      tout, note, alter, delta = [$1, $2, $3, $4]
      liste_notes << {
        :whole => tout,
        :note => note, :alter => alter, :delta => delta, :notealt => "#{note}#{alter}"}
    }
        
    octave_courant  = @octave || 3
        
    previous_note   = nil
    liste_notes.each do |dnote|
      note_seule = dnote[:note]
      unless previous_note.nil?
        
        # On cherche la note la plus proche de la précédente
        the_closest = previous_note[:whole].closest( 
                        dnote[:whole], octave_courant 
                        )
        octave_courant = the_closest[:octave]
        
      else
        # La première note étudiée
      end
      dnote = dnote.merge(:octave => octave_courant)
      previous_note = dnote
    end
    
    # On produit une linote
    LINote::new(
      :note         => previous_note[:notealt],
      :octave_llp   => previous_note[:delta],
      :octave       => previous_note[:octave]
    )
    }.call
    
  end
  
  # => Return (et définit) les notes du motif en array explodé
  # Cf. LINote::explode
  def exploded
    return nil if @notes.nil?
    @exploded ||= LINote::explode self
  end
  
  # => Méthode de commodité
  def as_motif
    self
  end
  
  # =>  Inscrit la durée +duree+ pour toutes les notes du motif
  #     sauf si +duree+ est nil
  # 
  # Cf. LINote::fixe_notes_length pour le détail
  # 
  # @param  duree   La durée à appliquer aux notes (la première
  #                 seulement, en général)
  #                 Si non fourni, prends la valeur de la propriété
  #                 @duration.
  # 
  # @return la suite des notes (String), prêtes à inscription
  # 
  def notes_with_duree duree = nil
    duree ||= @duration
    return LINote::fixe_notes_length( self.notes, duree )
  end
  
  # =>  Retourne les @notes du motif (ou les +notes+ passés en 
  #     paramètres) avec la marque de slur ou de legato
  def notes_with_liaison notes = nil
    notes ||= @notes
    return notes unless @slured || @legato
    markin  = @slured ? '(' : '\('
    markout = @slured ? ')' : '\)'
    LINote::pose_first_and_last_note notes, markin, markout
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
    Score::mark_relative( octave + ajout )
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
  
  
  # => Retourne l'objet slured (liaisons simples)
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
  
  # => Crée un crescendo à partir du motif
  # 
  # @param  params  Options:
  #                   :start    La dynamique de départ (if any)
  #                   :end      La dynamique de fin (if any)
  #                   :new      Crée une nouvelle instance si true, sinon
  #                             modifie l'objet courant
  def crescendo params = nil;   cresc_or_decresc params, true   end
  def decrescendo params = nil; cresc_or_decresc params, false  end
  def cresc_or_decresc params, for_crescendo
    params ||= {}
    start   = params.has_key?( :start ) ? "\\#{params[:start]} " : ''
    markin  = for_crescendo ? '\<' : '\>'
    markout = params.has_key?( :end   ) ? " \\#{params[:end]}" : '\!'
    notes_str = LINote::pose_first_and_last_note @notes, markin, markout
    # @todo: fonctionner comme pour @slured et @legato : en appliquant la marque seulement dans to_s
    motif_leg = "#{start}#{notes_str}"
    change_objet_ou_new_instance motif_leg, params, true
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

    # Définir l'octave du motif
    # -------------------------
    octave =  if params.has_key?( :octave ) && params[:octave] != nil
                params[:octave]
              else 
                @octave
              end

    # Instance nouvelle ou courante modifiée
    if params[:new] === true
      Motif::new( :notes  => new_motif, 
                  :octave => octave )
    else
      @notes  = new_motif
      @octave = octave
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