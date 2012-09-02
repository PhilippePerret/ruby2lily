# 
# Class Staff (Portée)
# 
class Staff

  unless defined?(Staff::CLE_FR_TO_EN)
    CLE_FR_TO_EN = {
      'sol' => 'treble',
      'G'   => 'treble',
      'ut3' => 'alto',
      'U3'  => 'alto',
      'ut4' => 'tenor',
      'U4'  => "tenor",
      'fa'  => 'bass',
      'F'   => 'bass'
    }
    CLE_EN_TO_FR = CLE_FR_TO_EN.invert
  
    ERRORS = {
      :bad_tempo_value  => "Mauvaise valeur pour le tempo",
      :bad_value_clef   => "Mauvaise valeur pour la clé (soit #{CLE_FR_TO_EN.keys.join(', ')}, soit #{CLE_FR_TO_EN.values.join(', ')})"
    }
  end
  
  # -------------------------------------------------------------------
  #   L'instance
  # -------------------------------------------------------------------
  attr_reader :tempo, :tempo_str, :base_tempo, :clef, :octave_clef
  @tempo        = nil
  @tempo_str    = nil     # Le tempo exprimé en string
  @base_tempo   = nil     # La durée de référence pour le tempo (un
                          # entier correspondant à la durée lilipond)
  @clef         = nil     # La clé
  @octave_clef  = nil     # Le nombre d'octaves modifiant la clé
  @time         = nil     # La signature
  
  def initialize data = nil
    unless data.nil?
      if data.has_key?( :tempo ) && !data[:tempo].nil?
        self.tempo= data[:tempo] 
      end
      @base_tempo   = data[:base_tempo]
      if data.has_key?( :clef ) && !data[:clef].nil?
        self.clef= data[:clef]
      end
      @octave_clef  = data[:octave_clef]
      @time         = data[:time]
    end
  end
  # => Définit le tempo
  # @param  valeur      Soit un nombre (métronome), soit une valeur
  #                     string comme "Andante", "Allegro", etc.
  # @param  base        Si +valeur+ est un nombre, la durée lilipond de
  #                     référence, 0 pour une ronde, 4 pour une noir,
  #                     "4." pour une noire pointée, etc.
  def tempo= valeur
    if valeur.class == String
      @tempo_str = valeur.capitalize
    elsif valeur.class == Fixnum && valeur > 0
      @tempo      = valeur
    else
      raise Staff::ERRORS[:bad_tempo_value]
    end
  end
  def base_tempo= valeur
    @base_tempo = valeur
  end
  
  # => Définit la clé
  def clef= cle, octave = nil
    if CLE_FR_TO_EN.has_key? cle.to_s
      @clef = CLE_FR_TO_EN[cle.to_s]
    elsif CLE_EN_TO_FR.has_key? cle.to_s
      @clef = cle.to_s
    else
       @clef = nil
      raise ERRORS[:bad_value_clef]
    end
    if octave.nil?
      @octave_clef = nil
    else
      @octave_clef = octave
    end
  end
  
  # -------------------------------------------------------------------
  #   Méthodes d'affichage
  # -------------------------------------------------------------------
  
  # => Retourne le code Lilipond pour la portée
  def to_llp
    clef    = mark_clef
    mclef   = clef.nil? ? "" : "\n#{clef}"
    tempo   = mark_tempo
    mtempo  = tempo.nil? ? "" : "\n#{tempo}"
    "{#{mclef}#{mtempo}\n}"
  end
  alias :to_lilipond :to_llp
  
  # => Retourne la marque pour le tempo dans la portée
  def mark_tempo
    return nil if @tempo.nil? && @tempo_str.nil?
    mk_base = @base_tempo.nil? ? "4" : @base_tempo
    mk_strg = @tempo_str.nil? ? "" : " \"#{tempo_str}\""
    "\t\\tempo#{mk_strg} #{mk_base} = #{@tempo}"
  end
  
  # => Retourne la marque pour la clé dans la portée
  def mark_clef
    "\t\\clef \"#{@clef || 'treble'}\""
  end
  
  # => Return la signature pour la partition lilypond
  def mark_time
    @time ||= SCORE.time || "4/4"
    "\t\\time #{@time}" # warning: pas de guillemets
  end
  
  # => Return l'armure pour la partition
  def mark_key
    return nil if SCORE.key.nil? || SCORE.key == "C"
    data_key = LINote::TONALITES[SCORE.key]
    "\t\\key #{data_key['llp']} \\major"
  end
end