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
  #   Classe
  # -------------------------------------------------------------------
  @@index_voice = nil     # Pour numéroter les voix si pas de nom
  
  def self.uniq_name
    @@index_voice ||= 0
    @@index_voice += 1
    "voice_unnamed_#{@@index_voice}"
  end
  
  # -------------------------------------------------------------------
  #   L'instance
  # -------------------------------------------------------------------
  @paroles        = nil   # Instance Voice::Lyrics pour les paroles
  
  def initialize data = nil
    super( data )
    @octave_defaut  = 4
  end
  
  # => Retourne le code à inscrire dans la partition
  # 
  # @note: overwrite la méthode Instrument
  def to_lilypond params = nil
    return false unless @displayed
    @staff = Staff::new(
                        :clef         => @clef, 
                        :tempo        => SCORE.tempo, 
                        :base_tempo   => SCORE.base_tempo,
                        :octave_clef  => @octave_clef
                        )

    <<-EOS
    
<<
  \\new Voice = "#{uniq_name}" {
    #{staff_header(params).gsub(/\n/, "\n\t")}
    #{staff_content.gsub(/\n/, "\n\t")}
  }
  \\new Lyrics \\lyricsto "#{uniq_name}" {
    #{paroles.to_s}
  }
>>

    EOS
  end
  
  # Retourne un nom unique pour la voix
  def uniq_name
    @uniq_name ||= lambda {
      if @name.nil? 
        Voice::uniq_name 
      else
        @name.downcase.gsub(/ /, '_').gsub(/[^a-z_]/,'')
      end
    }.call
  end
  
  def paroles
    @paroles ||= Lyrics::new self
  end
  alias :lyrics :paroles
  
  
  # -------------------------------------------------------------------
  #   La sous-classe Lyrics
  # -------------------------------------------------------------------
  class Lyrics
    
    # -------------------------------------------------------------------
    #   Instance
    # -------------------------------------------------------------------
    @ivoice = nil     # L'instance Voice des paroles de l'instance
    @lyrics = nil     # Les paroles, en string
    # => Instanciation des paroles de la chanson
    def initialize ivoice = nil
      @ivoice = ivoice
    end
    
    # => Ajoute des paroles pour la Voice
    def add paroles
      @lyrics ||= ""
      @lyrics = "#{@lyrics} #{paroles}".strip
    end
    alias :<< :add
    
    # => Retourne les paroles en simple string
    def to_s
      @lyrics
    end
  end
end