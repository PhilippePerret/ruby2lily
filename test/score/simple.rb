# 
# NE PAS MODIFIER OU SUPPRIMER CE FICHIER : IL SERT POUR LES TESTS
# 
@title    = "Partita"
@composer = "J.S. Bach"
@opus     = "1"
@tempo    = 120
@time     = "6/8"

def orchestre
  <<-ORC

      name    instrument    clef    tune
    -------------------------------------------------------------------
      GIT1    Guitar        -       -
    -------------------------------------------------------------------
    
  ORC
end

def score
  GIT1.add "b f c fis fis c gis' d<a c e>8 c8( b c d c b)"
  GIT1.add "a( g f e f g)"
end
