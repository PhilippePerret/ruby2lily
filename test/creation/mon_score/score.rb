@title    = "Mon Score"
@composer = "COMPOSITEUR"
@key      = "TONALITÉ"
@time     = "4/4"
@tempo    = 120

def orchestre
  <<-EOO
    
      instrument  class         staff
    -------------------------------------------------------------------
      INSTRU      Instrument    StaffName
    -------------------------------------------------------------------
    
  EOO
end

def score
  # Composer les motifs, les accords, etc.
  mot1    = Motif::new "c d e f", :slured => true
  acc_do  = Chord::new "c e g", :octave => 4
  # Ajouter à l'instrument
  INSTRU << "a b c" + mot1 + acc_do
end
