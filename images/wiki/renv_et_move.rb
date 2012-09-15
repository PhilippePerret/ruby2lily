@title = "Renversement et degrés"


def orchestre
  <<-EOO
    
      name    instrument    Staff
    -------------------------------------------------------------------
      ORGUE   Voice    Orgue
    -------------------------------------------------------------------
    
  EOO
end


def score
  
  acc_do = Chord::new "c e g", :octave => 4, :duree => "1"
  acc_sol = acc_do.move(5).renverse(2)
  acc_fa  = acc_do.to_degre(4).renverse(2)
  ORGUE << acc_do + acc_fa + acc_sol + acc_do.renverse

end