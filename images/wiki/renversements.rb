@title = "Accord en position normale"

def orchestre
  <<-EOO
    
      name    instrument    Staff
    -------------------------------------------------------------------
      JANE   Voice    Accord
    -------------------------------------------------------------------
    
  EOO
end

def score
  accord = Chord::new "c e g b", :octave => 1
  JANE << accord.renverse(3)[2]
end