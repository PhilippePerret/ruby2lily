# 
# NE PAS MODIFIER OU SUPPRIMER CE FICHIER : IL SERT POUR LES TESTS
# 
@title    = "Partita"
@composer = "J.S. Bach"
@opus     = "1"
@tempo    = 120
@time     = "4/4"

def orchestre
  <<-ORC

      instrument  class       staff
    -------------------------------------------------------------------
      GIT1        Voice        -       -
      GIT2        Guitar      deuxieme_guitare
    -------------------------------------------------------------------
    
  ORC
end

def score
  # motif = Motif::new :notes => "r4\\( <ais c e> geses8( b[ e4])\\) r2 <c'' e g c>", :octave => 3
  # motif = Motif::new "d e f", :duration => croche, :octave => 4
  mesure1 = "a4 b c d"
  mesure2 = "e f g a"
  mesure3 = "b c d e"
  mesure4 = "f g a b"
  GIT1 << mesure1 
  GIT1 << mesure2
  GIT1 << mesure3 + mesure4
  GIT2 << mesure4 + mesure3 + mesure2 + mesure1
end
