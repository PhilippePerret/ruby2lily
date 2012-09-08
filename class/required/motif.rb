# 
# CLass Motif
# 

require 'noteclass'

class Motif < NoteClass
  
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
  # => Instanciation
  # 
  # @param  params  Paramètres définissant le nouveau motif.
  #         Peut être :
  #         - un string définissant les notes
  #         - un array de motifs
  #         - un hash contenant :notes et :octave pour définir
  #           précisément la hauteur du motif.
  def initialize params = nil
    @notes    = nil
    @octave   = 3
    @duration = nil
    case params.class.to_s
    when "String" then set_with_string params
    when "Array"  then @notes = params # Liste de motifs
    when "Hash"   then set_with_hash params
    end
  end
  
  # => Définit l'instance Motif à partir d'un Hash de données
  # 
  # @todo: Test de validité du hash transmis à la méthode
  def set_with_hash hash
    @notes    = hash[:notes]
    @octave   = hash[:octave].to_i unless hash[:octave].nil?
    @duration = hash[:duration] || hash[:duree]
    @duration = @duration.to_s unless @duration.nil?
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
    
    if @notes.class == String

      # --- Motif string --- #

      # Mark relative (\\relative c...) pour le motif
      # ----------------------------------------------
      mk_relative = mark_relative octaves_to_add

      # Changement des durées si nécessaire
      notes_str = if duree.nil? then @notes 
                  else notes_with_duree(duree) end 
      # Finalisation
      return "#{mk_relative} { #{notes_str} }"

    else
      
      # --- Notes de motifs --- #

      pms = { :add_octave => octaves_to_add }
      pms = pms.merge(:duration => duree) unless duree.nil?
      return @notes.collect { |mo| mo.to_s(pms) }.join(' ')
      
    end
  
  end
  
  # => Return le motif au format lilypond (MAIS sans la marque d'octave)
  def to_llp
    notes_with_duree
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
      res = @notes.scan(/([a-g](eses|isis|es|is)?)/)
      fatal_error(:unable_to_find_first_note_motif, :notes => @notes ) \
        if res.nil? || res.first.nil?
      note = res.first.first
      LINote::new :note => note, :octave => @octave
    }.call
  end
  # => Return la dernière note (donc pas un silence) du motif
  # 
  # @note: la difficulté par rapport à first_note est qu'il faut calculer
  # ici, suivant la suite de notes, la hauteur réelle de la dernière :
  # Car dans :
  #   "c c"   La 1ère et la dernière sont à la même octave
  # tandis que dans :
  #   "c e g c" La dernière ("c") est une octave au-dessus de la 1ère
  def last_note
    return nil if @notes.nil?
    @last_note ||= lambda {
      
    oui = $DEBUG === true
    puts "\n\n=== DÉBUG ===" if oui
    puts "Trouver la dernière note de #{self.notes}" if oui
    # NOUVELLE MÉTHODE
    # On ne conserve que les notes, les altérations et les marques d'octaves
    liste_notes = []
    " #{@notes}".gsub(/ (?:<?([a-g])(eses|isis|es|is)?([',]*))/){
      note, alter, delta = [$1, $2, $3]
      liste_notes << {:note => note, :alter => alter, :delta => delta, :notealt => "#{note}#{alter}"}
    }
    
    puts "liste_notes: #{liste_notes.inspect}" if oui
    
    octave_courant  = @octave || 3
    
    puts "octave courant : #{octave_courant}" if oui
    
    previous_note   = nil
    liste_notes.each do |dnote|
      puts "---\n* Étude de #{dnote.inspect}" if oui
      note_seule = dnote[:note]
      unless previous_note.nil?
        
        curr_is_after_prev = note_seule.after? previous_note[:note]
        puts "Courante après prévious ? #{curr_is_after_prev ? 'oui' : 'non '}" if oui
        interval = dnote[:notealt].interval_with previous_note[:notealt]
        puts "Intervalle : #{interval}" if oui
        interval_abs = interval.abs
        
        # Y a-t-il changement d'octave
        if dnote[:note] == previous_note[:note]
          puts "Les notes sont identiques, donc même octave (hors delta)" if oui
          octave_courant = octave_courant # pour la clarté
        elsif interval_abs <= 6
          puts "L'intervalle est entre -6 et 6" if oui
          if curr_is_after_prev
            puts "Je garde la même octave" if oui
            octave_courant = octave_courant # pour la clarté
          else
            octave_courant += interval >= 0 ? 1 : -1
            puts "Je mets l'octave à #{octave_courant} puisque la note est avant" if oui
          end
        else # Si l'interval et < -6 ou > 6
          octave_courant += curr_is_after_prev ? -1 : 1
          puts "Je mets l'octave à #{octave_courant} puisque l'intervalle est hors -6 <-> 6" if oui
        end
        
        # On ajoute éventuellement le delta d'octave de la note courante
        delta_octaves = LINote::octaves_from_llp dnote[:delta]
        puts "Le delta est de #{delta_octaves}" if oui
        octave_courant += delta_octaves
        puts "L'OCTAVE FINAL EST DONC : #{octave_courant}" if oui
      else
        # La première note étudiée
      end
      dnote = dnote.merge(:octave => octave_courant)
      previous_note = dnote
      puts "Prévious note mise à :#{previous_note.inspect}" if oui
    end
    
    # On retourne une linote
    linote = LINote::new(
      :note         => previous_note[:notealt],
      :octave_llp   => previous_note[:delta],
      :octave       => previous_note[:octave]
    )
    puts "*** Linote obtenu (donc dernière note) : #{linote.inspect}" if oui
    linote
    }.call
    
    # @last_note ||= lambda {
    #   octave = @octave
    #   current_note = nil
    #   exploded.each do |linote|
    #     next if linote.rest?
    #     unless current_note.nil?
    #       # On définit l'octave de la linote courante
    #       # La dernière contiendra la valeur cherchée
    #       # @note: il faut passer en revue chaque note impérativement,
    #       # car il faut suivre l'avancée des octaves. Par exemple, 
    #       # comment savoir à quelle hauteur sera le dernier do de :
    #       # "c e g c e g c e g" sans calculer note à note ?
    #       LINote::set_octave_last_linote current_note, linote
    #     else
    #       linote.instance_variable_set("@octave", octave)
    #     end
    #     current_note = linote
    #   end
    #   fatal_error(:unable_to_find_last_note_motif, :notes => @notes ) \
    #     if current_note.nil?
    #   current_note # retourné à @last_note
    # }.call
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
    "\\relative #{LINote::mark_octave( octave + ajout )}"
  end
  
  # -------------------------------------------------------------------
  #   Opérations sur motif
  # -------------------------------------------------------------------

  require 'module/operations.rb' # normalement, toujours chargé
  include OperationsSurNotes
    # Définit +, * et []
  
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
  
  # => Retourne le motif avec les notes liées
  # 
  # @return L'OBJET LUI-MÊME (contrairement à d'autres méthodes de
  # transformation)
  def legato params = nil
    motif_leg = pose_first_and_last_note '(', ')'
    change_objet_ou_new_instance motif_leg, params, false
  end
  
  # => Retourne le motif avec les notes sur-liées (*)
  # 
  # (*) Cette méthode est à utiliser quand le motif contient déjà des
  # liaisons slur
  # 
  # @return L'OBJET LUI-MÊME (contrairement à d'autres méthodes de
  # transformation)
  def surlegato params = nil
    motif_leg = pose_first_and_last_note '\(', '\)'
    change_objet_ou_new_instance motif_leg, params, false
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
    motif_leg = "#{start}#{pose_first_and_last_note(markin, markout)}"
    change_objet_ou_new_instance motif_leg, params, true
  end
  
  
  # =>  Pose une marque de début (donc après la première note) et de fin
  #     (donc après la dernière note) sur le motif de l'objet courant
  # 
  # @return   Le motif courant modifié
  def pose_first_and_last_note markin, markout
    dmotif = @notes.split(' ') # => vers des notes mais aussi des marques
    ifirst = 0
    while dmotif[ifirst].match(/^[a-g]/).nil? do ifirst += 1 end
    dmotif[ifirst] = "#{dmotif[ifirst]}#{markin}"
    ilast = dmotif.count - 1
    while dmotif[ilast].match(/^[a-g]/).nil? do ilast -= 1 end
    dmotif[ilast] = "#{dmotif[ilast]}#{markout}"
    dmotif.join(' ')
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