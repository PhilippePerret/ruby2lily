# 
# Class Bass < Instrument
# 
class Bass < Instrument
  # -------------------------------------------------------------------
  #   L'instance
  # -------------------------------------------------------------------
  
  def initialize data = nil
    super( data )
    @clef = "F"
  end
  
  # Overwrite la méthode par défaut
  def mark_relative
    "relative c'"
  end
  
end