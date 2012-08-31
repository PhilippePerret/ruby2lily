# 
# Class Orchestre
# 

class Orchestre
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  @data_orchestre   = nil   # Les data complètes de l'orchestre
  @tonalite_defaut  = nil   # Tonalité par défaut (la première trouvée)
  
  def initialize
  end
  
  def compose orchestre_str
    puts "--> Orchestre::compose"
    puts "• orchestre_str: #{orchestre_str}"
    @data_orchestre = orchestre_str.to_array
    puts "[Orchestre::compose] @data_orchestre: #{@data_orchestre.inspect}"
    
    # On cherche le premier ton défini
    @tonalite_defaut = nil
    @data_orchestre.each do |data|
      if data[:ton] != nil
        @tonalite_defaut = data[:ton]
        break
      end
    end
    # On transforme chaque instruments en classe Instrument
    @data_orchestre.each do |d_instrument|
      d_instrument[:ton] ||= @tonalite_defaut
      instrument = d_instrument[:instrument]
      eval "#{instrument} = Instrument::new(#{d_instrument.inspect})"
    end
    
  end
  
end