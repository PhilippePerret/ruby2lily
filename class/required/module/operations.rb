# 
# 
# Module contenant les méthodes opérations valables pour les
# String, Note, Motif et Chord
# 

module OperationsSurNotes

  # => Addition
  # ------------
  # Cette méthode d'instance, héritée par Note, Chord (et autres
  # à l'avenir) SAUF MOTIF (stack level too deep) permet de gérer les 
  # additions. 
  # Chacune de ces sous-classes doit pouvoir être ajoutée à une autre en
  # créant un
  # nouveau motif.
  #
  # @note:  self ne peut pas être de type String (géré dans l'extension
  #         de la classe String)
  # 
  # @param  foo   Soit :
  #                 - Un string
  #                 - Une Note
  #                 - Un Motif
  #                 - Un Chord
  def + foo
    # Cas spécial de deux motifs (appelé notamment en bas de cette
    # méthode, d'où le `return' ci-dessous)
    if self.class == Motif && foo.class == Motif
      return self.join( foo, :new => true )
    else
      begin
        motif_gauche = self.as_motif
      rescue NoMethodError => e
        fatal_error(:cant_add_this, :classe => self.class.to_s)
      end
      begin
        motif_droit = foo.as_motif
      rescue NoMethodError => e
        fatal_error(:cant_add_this, :classe => foo.class.to_s)
      end
      motif_gauche + motif_droit # rappelle cette méthode mais cf. haut
    end    
  end # / +
  
  # => Multiplication
  # 
  # @param  nombre_fois   Membre droit de la multiplication
  # @param  params        Paramètres optionnels. Par exemple :
  #                         :new => false pour modifier le self, quand
  #                         c'est un motif qui est multiplié.
  # @note   +self+ sera transformé en motif pour être multiplié
  # 
  def * nombre_fois, params = nil
    
    if self.class == Motif
      motif = self
      as_nouveau_motif = true
    else
      motif = self.as_motif
      as_nouveau_motif = false
    end
    
    motif.change_objet_ou_new_instance(
      "#{motif.notes} ".x(nombre_fois).strip,
      params,
      as_nouveau_motif
    )
    # "#{mark_relative} { #{@notes} } ".x(nombre_fois).strip
    
  end
  
end