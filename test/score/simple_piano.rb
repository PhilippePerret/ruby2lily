@title      = "Piano simple"
@composer   = "Philippe Perret"
@instrument = "Piano"
@description = <<-EOE
Une partition simple pour le piano, pour voir s'il s'écrira bien de façon 
générale
EOE

def orchestre
  <<-EOO
    
    name    instrument      clef      key
  -------------------------------------------------------------------
    PIANO   Piano           -         -
  -------------------------------------------------------------------
  
  EOO
end

def score
  PIANO.main_droite << "b4 c d e"
  PIANO.main_gauche << "g4 a b c"
  acc_d = Chord::new "g b e f"
  acc_gfirst = Chord::new "g, g'"
  acc_g = Chord::new "g g'"
  PIANO.droite << acc_d.to_s(8) + acc_d.to_s + acc_d.to_s + acc_d.to_s
  PIANO.gauche << acc_gfirst.to_s(8) + acc_g.to_s + acc_g.to_s + acc_g.to_s
end