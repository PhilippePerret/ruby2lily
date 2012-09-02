# 
# CLass Motif
# 
class Motif
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  @motif = nil  # Le motif (String)
  def initialize params = nil
    case params.class.to_s
    when "String" then @motif = Liby::notes_ruby_to_notes_lily(params)
    else
      @motif = nil
    end
  end
  
  # =>  Return le motif en string avec l'ajout de la durée +duree+ si 
  #     elle est spécifiée
  def to_s params = nil
    return nil if @motif.nil?
    if params.class == Fixnum || params.class == String
      duree = params.to_s
      params = {}
      params[:duree] = duree
    elsif params.nil?
      params = {}
    end
    return @motif unless params.has_key?(:duree) && params[:duree]!=nil
    params[:duree] = params[:duree].to_s
    @motif.split(' ').collect{ |e| e + params[:duree]}.join(' ')
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
    motif_leg = pose_legato
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
    motif_leg = pose_legato true
    change_objet_ou_new_instance motif_leg, params, false
  end
  
  def pose_legato surlegato=false
    markin  = surlegato ? '\(' : '('
    markout = surlegato ? '\)' : ')'
    dmotif = @motif.split(' ') # => vers des notes mais aussi des marques
    dmotif[0] = "#{dmotif[0]}#{markin}"
    ilast = dmotif.count - 1
    while dmotif[ilast].match(/^[a-g]/).nil?
      ilast -= 1
    end
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