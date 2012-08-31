# 
# Class Staff (Portée)
# 
class Staff

  CLE_FR_TO_EN = {
    'sol' => 'treble',
    'ut3' => 'alto',
    'ut4' => 'tenor',
    'fa'  => 'bass'
  }
  CLE_EN_TO_FR = CLE_FR_TO_EN.invert
  
  ERRORS = {
    :bad_tempo_value  => "Mauvaise valeur pour le tempo",
    :bad_value_clef   => "Mauvaise valeur pour la clé (soit #{CLE_FR_TO_EN.keys.join(', ')}, soit #{CLE_FR_TO_EN.values.join(', ')})"
  }
  
  
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
      raise ERRORS[:bad_value_clef]
    end
    if octave.nil?
      octave_clef = "4"
    else
      octave_clef = octave
    end
  end
  
  # -------------------------------------------------------------------
  #   Méthodes d'affichage
  # -------------------------------------------------------------------
  
  # => Retourne le code Lilipond pour la portée
  def to_llp
    llp = []
    llp << "{"
    # ... ici le traitement
    tempo = mark_tempo
    clef  = mark_clef
    llp << clef   unless clef.nil?
    llp << tempo  unless tempo.nil?
    llp << "}"
    llp.join("\n")
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
    return nil if @clef.nil?
    "\t\\clef \"#{@clef}\""
  end
end