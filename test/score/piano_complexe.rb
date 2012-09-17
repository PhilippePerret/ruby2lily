@title = "Piano plus complexe"
@composer = "Phil"
@instrument = "Piano"

def orchestre
  <<-EOO
    instrument  class    staff
  ----------------------------------------------
    JANE        Voice     -
    PIANO       Piano     -
  ----------------------------------------------
  EOO
end


def score
  # Un accord de do tout bête
  accdo   = Chord::new "c e g"
  # Le riff à partir de l'accord, genre Bossa
  riff_do = Motif::new accdo.to_s(8) + accdo.to_s(4) * 3 + accdo.to_s(8)
  # 3 mesures en déplaçant l'accord
  trois_mesures = riff_do.to_s + riff_do.plus(2).to_s + riff_do.to_s 

  # Assemblage du piano
  PIANO.haut << trois_mesures + trois_mesures
  PIANO.bas  << "c4" * 12                     # Pédale de do pour commencer
  PIANO.bas  << "c" * 4 + "d" * 4 + "c" * 4  # Puis on suit  
end