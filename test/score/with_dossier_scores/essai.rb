@title = "Un essai avec dossier score"
@composer = "Phil"


def orchestre
  <<-EOO
    
      instrument  class    staff
    -------------------------------------------------------------------
      JEAN        Piano    Jean
    -------------------------------------------------------------------
    
  EOO
end

def score
  JEAN.gauche << JeanSolo.intro
end