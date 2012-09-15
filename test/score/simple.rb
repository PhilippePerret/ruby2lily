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

      name    instrument    clef    tune
    -------------------------------------------------------------------
      GIT1    Guitar        -       -
    -------------------------------------------------------------------
    
  ORC
end

def score
  # motif = Motif::new :notes => "r4\\( <ais c e> geses8( b[ e4])\\) r2 <c'' e g c>", :octave => 3
  motif = Motif::new "d e f", :duration => croche, :octave => 4
  motif.triolet("2/3")
  GIT1.add motif
end
