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
    end
    
    # Classe du premier membre
    # -------------------------
    # Détermine le motif gauche
    motif_gauche = 
      case self.class.to_s
      when "Chord", "String", "Note", "Motif"
        self.as_motif
      else
        # @todo : traiter d'un mauvais membre gauche
      end
    
    motif_droite =
      case foo.class.to_s
      when "String", "Note", "Motif", "Chord"
        foo.as_motif
      else
        fatal_error(:cant_add_this, :classe => foo.class.to_s)
      end
    
    motif_gauche + motif_droite # rappelle cette méthode mais cf. haut
    
  end # / +
  
end