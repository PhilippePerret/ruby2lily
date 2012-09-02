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
  
  def droite
    @main_droite ||= Instrument::new
  end
  alias :main_droite  :droite
  alias :right_hand   :droite
  alias :right        :droite
  alias :haut         :droite
  alias :high         :droite
  def gauche
    @main_gauche ||= Bass::new
  end
  alias :main_gauche  :gauche
  alias :left_hand    :gauche
  alias :left         :gauche
  alias :bas          :gauche
  alias :low          :gauche
  
  
  # -------------------------------------------------------------------
  #   Méthodes vers Lilypond
  # -------------------------------------------------------------------
  def to_lilypond
    c = []
    c << "\\new PianoStaff <<"
    c << "\t" + droite.to_lilypond.gsub(/\n/, "\n\t")
    c << "\t" + gauche.to_lilypond.gsub(/\n/, "\n\t")
    c << ">>"
    c.join("\n")
  end
  
end