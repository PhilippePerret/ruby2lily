# 
# La partition test
# 
# @todo: peut-être l'appeler 'score_example.rb' pour s'en servir
# comme exemple à proposer pour une nouvelle partition.
# 
def page
  @title      = "Partition à l'essai"     # Titre du morceau
  # @subtitle   = "Seulement pour essai"    # Sous-titre (if any)
  @composer   = "Philippe Perret"         # Compositeur
  # @parolier   = "Philippe Perret"         # Parolier (if any)
  @ton        = G                         # Tonalité
  @time       = "4/4"
end

def orchestre
  <<-HDEF

      instrument  class     staff     ton
    -------------------------------------------------------------------
      # Garder absolument SALLY et PIANO car les tests en ont besoin
      SALLY       Voice       -         -
      PIANO       Piano       -         -
      BASSE       Bass        -         -
      BATTERIE    Drums       -         -
    -------------------------------------------------------------------

  HDEF
end

def score
  
end