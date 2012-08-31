# 
# Class Voice < Instrument
# 
# Un instrument "Voice" est forcément composé d'une mélodie et
# de paroles.
# 

class Voice < Instrument
  
  # -------------------------------------------------------------------
  #   L'instance
  # -------------------------------------------------------------------
  @paroles = nil
  
  def initialize data = nil
    
    super( data )
  end
  
end