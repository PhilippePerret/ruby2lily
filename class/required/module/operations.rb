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
  # @principe : deux motifs sont issus de l'opération : le premier,
  #             normal et le second, qui doit contenir le delta d'octave
  #             par rapport au premier, pour que :
  #             "c e g" * 3 donne "c e g c, e g c, e g"
  # 
  def * nombre_fois, params = nil
    
    motif = if self.class == Motif
            as_new_motif = true
            self
          else
            as_new_motif = false
            self.as_motif
          end
    
    # On fait un double motif pour voir comment sera altéré le second
    double_motif = motif + motif
    # La suite du motif
    suite_motif = motif.to_llp
    suite_double_motif = double_motif.to_llp
    motif_suivant = suite_double_motif.sub(/#{suite_motif} /, '')
    # On procède à la multiplication
    motif_final = suite_motif.plus(" #{motif_suivant}".x(nombre_fois - 1))
    # On construit ou on modifie le motif
    motif.change_objet_ou_new_instance(
      motif_final, params, as_new_motif)
    
  end
  
  # =>  Retourne une nouvelle instance de l'objet (sauf si :new => false)
  #     avec les données définies dans les +params+
  #     S'utilise couramment pour définir la durée (en string) et
  #     l'octave. Par exemple :
  #       Soit le motif mo1
  #       mo1[4, "8."] va retourner un clone du motif, où l'octave est
  #       mis à 4 et la durée à 8.
  # 
  # @return : la nouvelle instance créée ou self si :new => false
  # 
  # @param  *params   cf. `params_crochet_to_hash'
  # 
  # @note: pour pouvoir fonctionner
  def []( *params)
    param1 = params[0]  # peut être nil
    param2 = params[1]  # peut être nil
    
    # Nouvelle instance (défaut) ou self
    if param1.class == Hash && param1.has_key?(:new) && param1[:new]
      new_inst = self
    else
      # new_inst = self.class::new self
      # J'essaie avec ça pour que ça fonctionne avec n'importe quel
      # classe d'objet.
      new_inst = self.clone
    end
    
    # puts "new_inst: #{new_inst.inspect}"
    
    # Analyse paramètres entre crochets
    # ----------------------------------
    # @note: gère toutes les erreurs possibles
    params = self.class::params_crochet_to_hash params
    # puts "params: #{params.inspect}"
    
    # Affectation des valeurs
    params.each do |property, value|
      new_inst.instance_variable_set("@#{property}", value)
    end
    # puts "new_inst réglé: #{new_inst.inspect}"
    
    # On retourne la nouvelle instance (ou self if any)
    new_inst
  end
  
end