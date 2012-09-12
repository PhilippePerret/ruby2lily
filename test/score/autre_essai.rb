@title = "Essai Nos Habitudes"
@composer = "Philippe Perret"
@key = "G"
@time = "4/4"

def orchestre
  <<-EOO
    
      name    instrument    Staff
    -------------------------------------------------------------------
      SALOME  Piano   Salomé
      BASS    Bass    Basse
    -------------------------------------------------------------------
    
  EOO
end

class Salome
  class << self
    def riff_ref
      @riff_ref ||= lambda {
        suite =     "r4 b( a8 d, a' b~ b4)"   \
              <<  " a4( a8 d, a'8 g~ g4)"     \
              <<  " g4( fis8 b, fis' g~ g4)"  \
              <<  " a4( a8 d, a'8 b~ b4)"
        Motif::new suite
      }.call
    end
    def riff_ref_main_gauche
      @riff_ref_main_gauche ||= lambda {
        riff_ref[:octave => 2, :clef => 'g']
      }.call
    end

    def riff_couplet
      suite = "e4. d4. d" \
              << " g,1 fis2. fis8 fis a g8"
      Motif::new suite
    end
  end
end

def score
  # Refrain / Intro
  SALOME.droite << Salome::riff_ref
  SALOME.gauche << Salome::riff_ref_main_gauche
  # Couplet
  SALOME.gauche << Salome::riff_couplet
end
