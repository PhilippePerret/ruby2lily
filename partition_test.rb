# 
# La partition test
# 
# @todo: peut-être l'appeler 'score_example.rb' pour s'en servir
# comme exemple.
# 

@title      = "Partition à l'essai"     # Titre du morceau
# @subtitle   = "Seulement pour essai"    # Sous-titre (if any)
@composer   = "Philippe Perret"         # Compositeur
# @parolier   = "Philippe Perret"         # Parolier (if any)
@ton        = G                         # Tonalité

@orchestre = <<-HDEF

    name        instrument  clef      ton
  -------------------------------------------------------------------
    SALLY       Voice       -         G
    PIANO       Piano       -         -
    BASSE       Bass        -         -
    BATTERIE    Drums       -         -
  -------------------------------------------------------------------
  
HDEF