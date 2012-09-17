@title = "Erreur dans les scores"
@composer = "Phil"

def orchestre
  <<-EOO
    
      instrument  class     staff
    -------------------------------------------------------------------
      PIANO       Piano     Piano
    -------------------------------------------------------------------
    
  EOO
end

def score
  PIANO << Piano::intro
end