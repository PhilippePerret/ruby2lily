# 
# Class Guitar < Instrument
# 
class Guitar < Instrument
  
  # NOTE : LA \clef sera : \clef "G_8"
  
  # -------------------------------------------------------------------
  #   L'instance
  # -------------------------------------------------------------------
  
  def initialize params = nil
    
    super( params )
    @octave_defaut = 3
  end
  
end