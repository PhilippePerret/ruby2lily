# 
# Class Guitar < Instrument
# 
class Guitar < Instrument
  
  # NOTE : LA \clef sera : \clef "G_8"
  
  # -------------------------------------------------------------------
  #   L'instance
  # -------------------------------------------------------------------
  @octave_defaut = 3
  
  def initialize data = nil
    
    super( data )
  end
  
end