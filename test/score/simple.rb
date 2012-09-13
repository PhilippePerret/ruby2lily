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
  GIT1.add "ges c"
  GIT1.add "<c f a>"
end
