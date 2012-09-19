# 
# Class Bass < Instrument
# 
class Bass < Instrument
  # -------------------------------------------------------------------
  #   L'instance
  # -------------------------------------------------------------------
  @octave_defaut = 1
  
  def initialize data = nil
    super( data )
    @clef = "F"
  end
  
end