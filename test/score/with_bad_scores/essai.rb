@title = "Erreur dans les scores"
@composer = "Phil"

def orchestre
  <<-EOO
    
      name    instrument    Staff
    -------------------------------------------------------------------
      PIANO   Piano    Piano
    -------------------------------------------------------------------
    
  EOO
end

def score
  PIANO << Piano::intro
end