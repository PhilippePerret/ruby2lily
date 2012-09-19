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
    @octave_defaut = 3
  end
  
end