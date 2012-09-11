@title = "Motifs enchaînés avec méthode crochets"
@composer = ""

@code = <<-COD
motif = Motif::new "a b c d"
JANE << motif[1, "8"].slure + motif[2, "4"].slure + motif[3, "4."].slure
COD

def orchestre
  <<-EOO
    
      name    instrument    Staff
    -------------------------------------------------------------------
      JANE    Voice         Jane
    -------------------------------------------------------------------
    
  EOO
end

def score
  motif = Motif::new "a b c d"
  JANE << motif[1, "8"].slure + motif[2, "4"].slure + motif[3, "4."].slure
end