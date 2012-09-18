# 
# Class Orchestre
# 

class Orchestre
  
  unless defined?(Orchestre::ERRORS)
    ERRORS = {
      :undefined_name       => "Le nom du musicien doit être toujours défini",
      :unknown_instrument   => "L'instrument \#{instrument} est inconnu…",
      :instrument_undefined => "L'instrument n'est pas défini, pour #{name}…"
    }
  end
  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :instruments
  
  @data_orchestre   = nil   # Les data complètes de l'orchestre
  @tonalite_defaut  = nil   # Tonalité par défaut (la première trouvée)
  @instruments      = nil
      # La liste des instruments (instances d'Instrument) 
      # Cette liste est définie par la méthode `orchestre` du score, mais
      # peut-être redéfinie par la ligne de commande ruby2lily, dans le
      # cas où seuls certains instruments doivent être affichés (extrait
      # de score). C'est elle qui est utilisée pour passer en revue les
      # instruments et construire leur portée
  
  def initialize
  end
  
  def compose orchestre_str
    
    Liby::fatal_error(:orchestre_undefined) if orchestre_str.nil?
    
    @instruments = []
    
    # puts "--> Orchestre::compose"
    @data_orchestre = orchestre_str.to_array

    # # = débug =
    # puts "@data_orchestre: #{@data_orchestre.inspect}"
    # # = /débug =
    
    # On cherche le premier ton défini si le ton n'a pas été défini
    # dans les données
    if SCORE.key.nil?
      @data_orchestre.each do |data|
        if data[:ton] != nil
          @tonalite_defaut = data[:ton]
          break
        end
      end
    else
      @tonalite_defaut = SCORE.key
    end
    # On transforme chaque instruments en classe Instrument qui sera
    # contenu par une constante.
    @data_orchestre.each do |d_instrument|
      # Le nom (= la constante qui sera utilisée)
      # name        = d_instrument[:name]
      name        = d_instrument[:instrument]
      if name.nil?
        Liby::fatal_error(Orchestre::ERRORS[:undefined_name]) 
      end
      
      # L'instrument (qui définira la classe du musicien)
      classe_instrument  = d_instrument.delete(:class)
      if classe_instrument.nil?
        Liby::fatal_error(Orchestre::ERRORS[:instrument_undefined], :name => name)
      else
        classe_instrument = classe_instrument.capitalize
      end
      unless Instrument::TYPES.has_key? classe_instrument.to_sym
        Liby::fatal_error(Orchestre::ERRORS[:unknown_instrument], :instrument => classe_instrument)
      end
      d_instrument[:ton] ||= @tonalite_defaut
      
      # On transforme les membres de l'orchestre en constantes globales
      cmd = "#{name} = #{classe_instrument}::new(#{d_instrument.inspect})"
      Kernel.class_eval cmd
      
      # On ajoute cet instrument à la liste des instruments
      @instruments << eval("#{name}")
    end
    
  end # / compose
  
  # => Return le code du score au format lilypond (hors accolades)
  # 
  # Le code est construit en passant en revue tous les instruments de
  # l'orchestre
  def to_lilypond
    @instruments.collect{|instrument|instrument.to_lilypond}.join("\n")
  end
  
  # => Return true si l'orchestre comprend plusieurs instruments
  def polyphonique?
    @instruments.count > 1
  end
end