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
  
end