@title = "Un essai avec dossier score"
@composer = "Phil"


def orchestre
  <<-EOO
    
      name    instrument    Staff
    -------------------------------------------------------------------
      JEAN    Piano         Jean
    -------------------------------------------------------------------
    
  EOO
end

def score
  # JEAN << JeanSolo::intro
  JEAN << "a b c d e f g"
end