# 
# Class Piano < Instrument
# 
# Un instrument de type "Piano" est forcément composé de deux portées,
# l'une appelée main_gauche et l'autre main_droite, chacune de classe
# Instrument
# 
class Piano < Instrument
  
  # -------------------------------------------------------------------
  #   L'instance
  # -------------------------------------------------------------------
  @main_droite = nil  # Définition de la main droite, instance de 
                      # Instrument
  @main_gauche = nil  # Définition de la main gauche, instance de class
                      # Instrument
                      
  def initialize data = nil
    
    super( data )
  end
  
  def main_droite
    @main_droite ||= Instrument::new
  end
  def main_gauche
    @main_gauche ||= Instrument::new
  end
end