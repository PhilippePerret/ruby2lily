# 
# Class d'Instrument Cello
# 
class Cello < Instrument
  
  def initialize params = nil
    super(params)
    @octave_defaut = 3
  end
  
end