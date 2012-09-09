=begin

  Class Voice < Instrument

  Un instrument "Voice" est forcément composé d'une mélodie et
  de paroles.


  @todo: si la voix a des paroles, on doit l'afficher sous la forme :
  <<
    \relative ... {
    
    }
    \addlyrics {
        ... ici les paroles ...
    }
  >>
  
  OU (qui d'après le manuel est moins limité) :
  <<
    \new Voice = "notes_voix" {
      \\relative c' { 
        ... notes ici ...
      }
    }
    \new Lyrics \lyricsto "notes_voix" {
      ... paroles ici ...
    }
  >>
  
  @todo: traitement de plusieurs voix :
  <<
    \relative .. {
    
    }
    \addlyrics
  >>
  En fait, ça revient à traiter comme une voix, mais en mettant tout
  dans un grand <<..>>
  => Quand un instrument de type Voice est créé, il faut le mémoriser
  dans la liste des voix, et faire ce grand bloc lilypond quand on
  demande l'affichage (donc il ne faut pas passer en revue toutes les
  voix)
  
=end
class Voice < Instrument
  
  # -------------------------------------------------------------------
  #   L'instance
  # -------------------------------------------------------------------
  @paroles = nil
  
  def initialize data = nil
    
    super( data )
  end
  
end