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
      # puts "\n\n== ADDITIONNER LES DEUX MOTIFS SUIVANT :"
      # puts "= self: #{self.inspect}"
      # puts "= foo : #{foo.inspect}\n\n"
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
      # puts "\n\nDans operation::+ :"
      # puts "motif_gauche: #{motif_gauche.inspect}"
      # puts "motif_droit: #{motif_droit.inspect}"
      
      motif_gauche + motif_droit # rappelle cette méthode mais cf. haut
    end    
  end # / +
  
  # => Multiplication
  # 
  # @param  fois      Membre droit de la multiplication
  # @param  params    Paramètres optionnels. Par exemple :
  #                       :new => false pour modifier le self, quand
  #                       c'est un motif qui est multiplié.
  # @note   +self+ sera transformé en motif pour être multiplié
  # 
  # @principe : deux motifs sont issus de l'opération : le premier,
  #             normal et le second, qui doit contenir le delta d'octave
  #             par rapport au premier, pour que :
  #             "c e g" * 3 donne "c e g c, e g c, e g"
  # 
  def * fois, params = nil
    
    params ||= {}
    self_is_motif = self.class == Motif

    # Le motif
    # ---------
    # Dans tous les cas, on fait un clone du motif, pour pouvoir
    # le modifier sans toucher au motif original dans la suite
    motif = self_is_motif ? self.clone : self.as_motif
    
    # Suite originale du motif
    motif_normal = "#{motif.to_llp}"

    # On regarde ce que donne la première note du motif lié à sa dernière
    prem = motif.first_note(strict = true)
    dern = motif.last_note( strict = true)
    
    # On transforme la première note comme si elle suivait la dernière
    unless prem.nil? || dern.nil?
      prem.as_next_of dern
      motif.set_first_note( prem, strict = true )
    end
    
    suivants = LINote::implode motif.exploded
    motif_final = motif_normal.plus( " #{suivants}".x(fois - 1) )

    # On construit ou on modifie le motif
    motif.change_objet_ou_new_instance(motif_final, params, self_is_motif)
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
    # -----------------------
    # Principe : si une méthode existe, portant le nom de la propriété,
    # c'est elle qu'on appelle avec la valeur (c'est le cas pour la
    # clef par exemple). Dans le cas contraire, on définit simplement
    # la valeur de la variable d'instance.
    # 
    params.each do |property, value|
      if new_inst.respond_to?("set_#{property}")
        new_inst.send("set_#{property}", value)
      else
        new_inst.instance_variable_set("@#{property}", value)
      end
    end
    
    # On retourne la nouvelle instance (ou self if any)
    new_inst
  end
  
end