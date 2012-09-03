# 
# CLass Motif
# 
class Motif
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :motif, :octave
  
  @motif  = nil   # Le motif (String)
  @octave = nil   # L'octave du motif (par défaut, c'est 2)
  
  # => Instanciation
  # 
  # @param  params  Paramètres définissant le nouveau motif.
  #         Peut être :
  #         - un string définissant les notes
  #         - un array de motifs
  #         - un hash contenant :motif et :octave pour définir
  #           précisément la hauteur du motif.
  def initialize params = nil
    @octave = 2 # pourra être redéfini par +params+
    case params.class.to_s
    when "String" then @motif = Liby::notes_ruby_to_notes_lily(params)
    when "Array"  then @motif = params
    when "Hash"   then 
      @motif  = Liby::notes_ruby_to_notes_lily(params[:motif])
      @octave = params[:octave].to_i unless params[:octave].nil?
    else
      @motif  = nil
    end
  end
  
  # =>  Return le motif en string avec l'ajout de la durée +duree+ si 
  #     elle est spécifiée
  # 
  # @note : @motif, ici, est soit un string de notes, soit une liste
  #         de motifs qu'il faut traiter séparément.
  # 
  # @note : on renvoie toujours le motif entouré par des :
  #         \\relative c''.. { ... }
  #         pour que les notes soient toujours interprétées par 
  #         rapport à la hauteur de l'instrument, pas la hauteur 
  #         atteinte. De cette façon, il n'y a aucun problème pour les
  #         additions et les multiplications.
  #         SAUF si @motif est une liste de motif, dans lequel cas 
  #         chacun d'eux sera interprété à sa manière
  # 
  # @param  params    
  #         Hash pouvant contenir :
  #            :duree        La durée à mettre aux notes du motif
  #            :octave       La hauteur à donner au motif
  #            :add_octave   Le nombre d'octaves à ajouter ou retrancher
  # 
  def to_s params = nil
    return nil if @motif.nil?
    
    # Analyse des paramètres transmis
    # --------------------------------
    params ||= {}
    params = {:duree => params} if [Fixnum, String].include? params.class
    # Durée pour les notes du motif (if any)
    duree_notes = params[:duree]

    # Définition de l'octave du motif
    # --------------------------------
    octaves_to_add =  if params.has_key? :octave
                        octave_from( params[:octave] )
                      elsif params.has_key? :add_octave
                        params[:add_octave]
                      else 0 end
    
    if @motif.class == String

      # --- Motif string --- #

      # Mark relative (\\relative c...) pour le motif
      # ----------------------------------------------
      mk_relative = mark_relative octaves_to_add

      # Changement des durées si nécessaire
      motif_str = if duree_notes.nil? then @motif 
                  else set_durees(duree_notes) end 
      # Finalisation
      return "#{mk_relative} { #{motif_str} }"

    else
      
      # --- Motif de motifs --- #

      pms = { :add_octave => octaves_to_add }
      pms = pms.merge(:duree => duree_notes) unless duree_notes.nil?
      return @motif.collect { |mo| mo.to_s(pms) }.join(' ')
      
    end
  
  end
  
  
  # =>  Inscrit la durée +duree+ pour toutes les notes du motif
  #     sauf si +duree+ est nil
  # 
  # Cf. LINote::fixe_notes_length pour le détail
  # 
  # @return la liste des notes, prêtes à inscription
  # 
  def set_durees duree
    return LINote::fixe_notes_length( self.motif, duree )
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
  # => Méthode d'addition de motif
  # 
  # @param  motif   Le motif à ajouter (mais peut très bien être un
  #                 simple string).
  # @param  params  Paramètres supplémentaire. 
  #                 Cf. `change_objet_ou_new_instance'
  # 
  # @note : l'addition se fait en conservant dans @motif les 
  #         deux motifs. Noter que les deux motifs peuvent être eux
  #         aussi des listes d'instances.
  def + autre_motif, params = nil
    new_motif = []
    if self.motif.class == String         then new_motif << self
    else new_motif += self.motif          end
    if autre_motif.motif.class == String  then new_motif << autre_motif
    else new_motif += autre_motif.motif   end
    change_objet_ou_new_instance new_motif, params, true
  end
  
  # => Méthode de multiplication de motif
  def *( nombre_fois )
    "#{mark_relative} { #{@motif * nombre_fois}}"
  end
  
  # -------------------------------------------------------------------
  #   Méthodes de transformation du motif
  # -------------------------------------------------------------------

  # => Retourne le motif baissé du nombre de +demitons+
  # @todo: plus tard, pourra modifier par degré, en restant dans la
  # gamme
  # 
  # @return une NOUVELLE instance de motif
  def moins demitons, params = nil
    # La question qui se pose ici est : 
    # Est-ce vraiment le bon moyen de repérer les notes dans un
    # motif ?
    new_motif = @motif.gsub(/\b([a-g](is|es)?(is|es)?)/){
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
    new_motif = @motif.gsub(/\b([a-g](is|es)?(is|es)?)/){
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
    dmotif = @motif.split(' ') # => vers des notes mais aussi des marques
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
    instance_returned = if params[:new] === true
                          Motif::new new_motif
                        else
                          @motif = new_motif
                          self
                        end
    # Réglage de l'octave du motif (nouveau ou courant)
    # Il doit toujours correspondre à l'octave du premier motif si
    # motif est constitué de plusieurs motifs.
    if instance_returned.motif.class == Array
      octave_first = instance_returned.motif.first.octave
      instance_returned.instance_variable_set("@octave", octave_first)
    end
    
    # Retourner l'instance Motif courante ou créée
    instance_returned
  end
  
  # => Définit la valeur de params[:new] si non défini
  def set_new_if_not_defined params, val_def
    params ||= {}
    return params if params.has_key? :new
    params[:new] = val_def
    params
  end
  
  
end