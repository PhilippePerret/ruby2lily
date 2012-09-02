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
  # @param  p_init    Hash pouvant contenir :
  #                   :duree    La durée à mettre aux notes du motif
  #                   :octave   Le nombre positif ou négatif d'octaves
  # 
  def to_s p_init = nil
    return nil if @motif.nil?

    # Analyse des paramètres transmis
    if p_init.class == Fixnum || p_init.class == String
      params = {}
      params[:duree] = p_init.to_i
    else
      params = p_init || {}
    end

    # Faire une liste de motifs, quel que soit le cas
    ary_motifs =  if self.motif.class == String then [self]
                  else @motif end

    # Calcul de l'octave de référence.
    # --------------------------------
    # Par exemple, si le motif est constitué de trois motifs différents
    # d'octave respectifs : 4, 2, -1
    # Et que params définit un octave de 3
    # Cela signifie qu'il faut baisser tout le motif d'une octave (≠ avec
    # le premier motif), donc que le 2e motif devra être mis à l'octave
    # 1 et le troisième à -2
    # 
    octa_to_add = if params.has_key? :octave
                    octa_needed = params[:octave].to_i
                    ary_motifs.first.octave - octa_needed
                  else 0 end
    
    # Boucle sur tous les motifs à mettre en forme
    ary_motifs_str = []
    ary_motifs.each do |mo|
      mo_str = mo.set_durees_in_motif params[:duree]
      num_octave = mo.octave + octa_to_add
      mk_rel = mo.mark_relative num_octave
      ary_motifs_str << "#{mk_rel} { #{mo_str} }"
    end
    ary_motifs_str.join(' ')
  end
  
  
  # =>  Inscrit la durée +duree+ pour toutes les notes du motif
  #     sauf si +duree+ est nil
  # 
  # @note : attention, pour le moment, la recherche des notes n'est
  # pas forcément pleinement opérationnelle. @todo: je pourrai la mettre
  # en place lorsque j'aurais fait le tour de toutes les syntaxes de 
  # lilypond
  # 
  # @note: @motif peut être maintenant soit un string soit un array
  # de motifs.
  # 
  # @return la liste des notes, prêtes à inscription
  # 
  def set_durees_in_motif duree
    if duree.nil? || duree < 1 || duree > 5000
      return @motif if @motif.class == String
    else
      return self.to_s
    end
    
    ary_motifs =  if @motif.class == String then [self]
                  else @motif end 
                    
    liste_notes = []
    regnote = %r{[a-g](?:(?:es|is){1,2})?}
    
    ary_motifs.each do |mo|
      # PROBLÈME ICI SI MOTIF DE MOTIFS (OÙ RENVOYER LA BOUCLE ?)
      mo.motif.split(' ').each do |membre|
        membre.gsub(/^(r|#{regnote})(?:[0-9]{1,3})?(.*?)$/){
          note_ou_rest, suite = [$1, $2]
          liste_notes << "#{note_ou_rest}#{duree}#{suite}"
        }
      end
      motif_prov = Motif::new liste_notes.join(' ')
      liste_notes << motif_prov.to_s
    end
    liste_notes.join(' ')
  end
  # =>  Renvoie la différence d'octave positive ou négative de 
  #     l'octave du motif (2 par défaut) avec +oct+
  def octave_from oct
    oct - octave
  end
  
  # => Retourne le '\relative c..' du motif
  # @param  oct   L'octave à utiliser, celui défini pour le motif le
  #               cas échéant
  # 
  # @return le texte '\relative c..'
  def mark_relative oct = nil
    oct ||= octave
    mk_oct = oct > 0 ? "'" : ","
    "\\relative c#{mk_oct.fois(oct.abs)}"
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
    debug "\nnew_motif: #{new_motif.inspect}"
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
  # @param  new_motif   Le nouveau motif obtenu par la méthode
  # @param  params      Les paramètres envoyés à la méthode
  # @param  new_defaut  La valeur de :new par défaut
  def change_objet_ou_new_instance new_motif, params, new_defaut
    params = set_new_if_not_defined( params, new_defaut )
    if params[:new] === true
      Motif::new new_motif
    else
      @motif = new_motif
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