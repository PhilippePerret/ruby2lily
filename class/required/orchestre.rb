# 
# Class Orchestre
# 

class Orchestre
  
  ERRORS = {
    :undefined_name       => "Le nom du musicien doit être toujours défini",
    :unknown_instrument   => "L'instrument \#{instrument} est inconnu…",
    :instrument_undefined => "L'instrument n'est pas défini, pour #{name}…"
  }
  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  @data_orchestre   = nil   # Les data complètes de l'orchestre
  @tonalite_defaut  = nil   # Tonalité par défaut (la première trouvée)
  
  def initialize
  end
  
  def compose orchestre_str
    
    Liby::fatal_error(:orchestre_undefined) if orchestre_str.nil?
    
    # puts "--> Orchestre::compose"
    @data_orchestre = orchestre_str.to_array

    # # = débug =
    # puts "@data_orchestre: #{@data_orchestre.inspect}"
    # # = /débug =
    
    # On cherche le premier ton défini
    @tonalite_defaut = nil
    @data_orchestre.each do |data|
      if data[:ton] != nil
        @tonalite_defaut = data[:ton]
        break
      end
    end
    # On transforme chaque instruments en classe Instrument qui sera
    # contenu par une constante.
    @data_orchestre.each do |d_instrument|
      # Le nom (= la constante qui sera utilisée)
      name        = d_instrument[:name]
      Liby::fatal_error(Orchestre::ERRORS[:undefined_name]) if name.nil?
      # L'instrument (qui définira la classe du musicien)
      instrument  = d_instrument.delete(:instrument)
      if instrument.nil?
        Liby::fatal_error(Orchestre::ERRORS[:instrument_undefined], :name => name)
      end
      unless Instrument::TYPES.has_key? instrument.to_sym
        Liby::fatal_error(Orchestre::ERRORS[:unknown_instrument], :instrument => instrument)
      end
      d_instrument[:ton] ||= @tonalite_defaut
      
      # On transforme les membres de l'orchestre en constantes globales
      cmd = "#{name} = #{instrument}::new(#{d_instrument.inspect})"
      Kernel.class_eval cmd
    end
    
  end
  
end