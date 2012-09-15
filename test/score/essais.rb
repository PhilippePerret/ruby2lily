@title = "Motif et méthode crochets"
@composer = ""

@code = <<-COD
motif = Motif::new \"a b c d\"
motif_final = motif[1, \"8.\"].slure
JANE << motif_final
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
  # motif = Motif::new "a b c d"
  # motif_final = motif[1, "8."].slure
  # JANE << motif_final
  motif = Motif::new "c", :octave => 4
  JANE << motif
end