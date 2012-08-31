# 
# Class Instrument
# 
# Pour créer et gérer les instruments de la partition.
# 
# @rappel: un instrument doit toujours être défini en capital pour 
# pouvoir être utilisé partout dans le programme.
# 
class Instrument
  
  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------
  TYPES = {
    :chant  => {},
    :piano  => {},
    :drum   => {},
    :corde  => {},
    :cuivre => {}
  }
  
  # -------------------------------------------------------------------
  #   La classe
  # -------------------------------------------------------------------
  @@instruments = nil       # La liste des instruments (instances)
  
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  @data       = nil   # Les data telles que définies dans @orchestre
  @type       = nil   # Le type (p.e. 'piano', 'chant', etc.)
  @instrument = nil   # L'instrument, c'est-à-dire la constante contenant
                      # l'instance Instrument courante.
  @ton        = nil   # La tonalité de la portée. C'est la tonalité du 
                      # morceau, par défaut, sauf pour les instruments
                      # transpositeur (p.e. sax en sib)
  @clef       = nil   # La clé générale pour l'instrument, parmi :
                      # G (sol), F (fa), U3 (ut 3e ligne), 
                      # U4 (ut 4e ligne)
  
  def initialize data = nil
    @data = data
    # puts "data : #{data.inspect}"
    data.each do |prop, value|
      instance_variable_set("@#{prop}", value)
    end unless data.nil?
  end
  
  # => Retourne un accord (instance Accord) de l'instrument
  def accord params = nil
    Chord::new params
  end
  alias :chord :accord
  
  # => Retourne les accords de l'instrument spécifiés par +params+
  def accords params
    
  end
  alias :chords :accords
  
  # => Retourne un motif (instance Motif) de l'instrument
  def motif params = nil
    Motif::new params
  end
  # => Retourne les motifs de l'instrument spécifiés par +params+
  def motifs params
    
  end
  
  # => Retourne une mesure (instance Mesure) de l'instrument
  def mesure params = nil
    Measure::new params
  end
  alias :measure :mesure
  
  # => Retourne les mesures de l'instrument spécifiées par +params+
  def mesures params
    
  end
  alias :measures :mesures
end