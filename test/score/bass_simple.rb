@title = "Nos Habitudes"
@subtitle = "Basse"
@time = "4/4"
@tempo = 100
@key = 'G'


def orchestre
  <<-EOO
    
      name    instrument      clef      ton
    -------------------------------------------------------------------
      BASS    Bass            -         -
    -------------------------------------------------------------------
  EOO
end

def score
  # On essaie en faisant un motif et en le transposant
  motif_bass_en_sol = Motif::new "g,4 r8 g g4 r8 g |"
  puts "motif_bass_en_sol: #{motif_bass_en_sol.inspect}"
  BASS.add motif_bass_en_sol
  BASS.add motif_bass_en_sol.moins(1)
  BASS.add motif_bass_en_sol.moins(3)
  BASS.add motif_bass_en_sol.moins(5)
  # Quelques motifs spéciaux
  motif_g_to_f_01 = Motif::new "r8 g, b g( gb f~) f2"
  motif_f_to_d_01 = Motif::new "r8 a16 a a8( f e d~) d1."
  BASS.add motif_g_to_f_01
  BASS.add motif_f_to_d_01
end