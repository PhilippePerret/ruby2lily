# 
# Classe Note
# 
# La classe d'une note
# 

require 'noteclass'

class Note < NoteClass

  # -------------------------------------------------------------------
  #   Opérations sur les notes
  # -------------------------------------------------------------------
  
  unless defined?(Note::ANGLO_TO_ITAL)
    ANGLO_TO_ITAL = {'a' => 'la', 'b' => 'si', 'c' => 'do', 'd' => 'ré', 'e' => 'mi', 'f' => 'fa', 'g' => 'sol'}
    ITAL_TO_ANGLO = ANGLO_TO_ITAL.invert
    ITAL_TO_ANGLO['re'] = "d" # ajout nécessaire
  
    NOTE_TO_VAL_ABS = {
      'c' => 1, 'd' => 3, 'e' => 5, 'f' => 6, 'g' => 8, 'a' => 10, 'b' => 12
    }
  
    ERRORS = {
      :bad_octave => "L'octave doit être un nombre compris entre -8 et 8"
    }
  end
  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------
  @@current_octave = nil
  
  # => Return la note +note+ avec les paramètres +params+
  def self.create_note note, params = nil
    params ||= {}
    params[:octave] ||= 3
    Note::new note, params
  end
  
  # =>  Sépare la note de la marque lilypond d'octave lorsqu'elle
  #     est fournie et return [note, octave/nil]
  def self.split_note_et_octave noteoct
    return [noteoct, nil] if noteoct.length == 1
    noteoct = LINote::to_llp noteoct
    note, octave = [noteoct[0..0], noteoct[1..-1]]
    octave_positive = octave.start_with? "'"
    octave = octave.length
    octave = octave.to_i * -1 unless octave_positive
    [note, octave]
  end
  
  def self.valeur_absolue note, octaves
    return nil if note == "r"
    nombre_dieses, nombre_bemols = dieses_et_bemols_in note
    NOTE_TO_VAL_ABS[note[0..0]] + # => 0 pour c
    (12 * octaves)        +
    (nombre_dieses * 1 )  +
    (nombre_bemols * -1)
  end
  
  # => Retourne le nombre de dièses et de bémols contenu dans +note+
  # 
  # @param note     Une note et une seule
  # @return [<nombre de dièse>, <nombre bémols>]
  def self.dieses_et_bemols_in note
    return nil if note.nil?
    [note.scan(/is/).count, note.scan(/es/).count]
  end
  # -------------------------------------------------------------------
  # @todo: peut-être supprimer les méthodes ci-dessous, qui ne servent peut-être pas
  # -------------------------------------------------------------------
  # => Retourne l'octave courant
  def self.current_octave
    @@current_octave
  end
  
  # => Définit l'octave courant
  def self.current_octave= valeur
    if valeur.class == Fixnum && valeur.between?(-8, 8)
      @@current_octave = valeur
    else
      raise Note::ERRORS[:bad_octave]
    end
  end
  class << self
    alias :octave_courant :current_octave
    alias :octave_courant= :current_octave=
  end
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :it, :octave, :duration
  
  @it         = nil       # La note, en notation anglosaxonne
  @alter      = nil       # L'alteration de la note (au format llp)
  @itit       = nil       # La note, en notation italienne
  @alter      = nil       # L'altération de la note
  @octave     = nil       # L'octave de la note (3 par défaut)
  @duration   = nil       # La durée, telle qu'exprimée pour Lilipond, i.e.
                          # 1 pour la ronde, 2 pour la noire, "4." pour
                          # la noire pointée, etc.
  @rest       = false     # Mis à true si c'est un silence
  
  # Instanciation de la Note
  # 
  # @param  note    La note, soit en anglais soit en italien (optionnel)
  # @param  params  Les paramètres initiaux pour la note
  def initialize note = nil, params = nil
    # Valeurs par défaut
    @rest     = false
    @octave   = 3
    @duration = nil
    set note unless note.nil?
    set_params params
  end
  
  def set valeur
    linote  = LINote::llp_to_linote( LINote::to_llp( valeur ) )
    @it     = linote.note
    unless linote.octave_llp.nil?
      @octave = 3 + LINote::octaves_from_llp( linote.octave_llp )
    end
    @rest = linote.rest?
    if @rest
      @it = @itit = nil
    else
      @itit   = ANGLO_TO_ITAL[@it]
      @alter  = linote.alter
    end
  end
    
  def get
    return nil if @it.nil?
    "#{@it}#{@alter}"
  end
  
  # => Return la note sous la forme d'un motif
  def as_motif
    Motif::new  :notes => "#{@it}#{@alter}", 
                :octave => @octave, 
                :duration => @duration
  end
  
  # -------------------------------------------------------------------
  #   Méthodes de type (note ou silence)
  # -------------------------------------------------------------------
  def to_rest
    @rest = true
  end
  alias :to_silence :to_rest
  def rest?
    @rest === true
  end
  alias :silence? :rest?
  
  # -------------------------------------------------------------------
  #   Méthodes de hauteur
  # -------------------------------------------------------------------
  
  # => Définit l'octave de la note
  def octave= octave
    if octave.class == Fixnum && octave.between?(-8, 8)
        @octave = octave
    else raise Note::ERRORS[:bad_octave] end
  end
  
  # -------------------------------------------------------------------
  #   Méthodes d'affichage
  # -------------------------------------------------------------------
  
  # => Définit la marque de durée (longueur et pointage)
  def mark_duration
    @duration.to_s
  end

  # => Renvoie la note telle qu'elle doit être affichée en lilipond
  # 
  # @note: pour n'obtenir que la note sans octave, utiliser la
  # méthode :get
  def to_s # => to_lilipond
    note = self.get
    note << @duration unless @duration.nil?
    unless rest? || @octave.nil? || @octave == 3
      mk_relative = Score::mark_relative(@octave)
      note = "#{mk_relative} { #{note} }"
    end
    note
  end
  alias :to_lilipond :to_s
  alias :to_llp :to_s
  
  # => Renvoie la note à l'octave supérieure ou inférieure
  # 
  # @param  modifier    Le "modifieur". Peut être :
  #                     nil       => octave supérieure
  #                     false/-1  => octave inférieure
  #                     entier    => nombre d'octaves inf ou sup
  def to_8 modifier = nil
    case modifier
    when nil, 1     then "#{@it}'"
    when false, -1  then "#{@it},"
    else
      if modifier.class == Fixnum
        oper = modifier > 0 ? "'" : ","
        "#{@it}#{oper.fois(modifier.abs)}"
      else
        raise "Le paramètre de :to_8 doit être un nombre, false ou nil"
      end
    end
  end
  
  # -------------------------------------------------------------------
  #   Méthodes de durée
  # -------------------------------------------------------------------
  
  # => Définit la durée
  # @param  duree   La durée, exprimée en nombre ou string
  #                 Par exemple : "2." ou 3
  def duree duree = nil
    return @duration if duree.nil?
    if duree.class == Fixnum && duree % 2 != 0 && duree != 1
      duree = ((duree / 2) + 1).to_s
      duree = "#{duree}."
    end
    @duration = duree.to_s
  end
  # -------------------------------------------------------------------
  #   Méthodes de durée renvoyant l'instance
  # -------------------------------------------------------------------
  def ronde;    duree 1;    self end
  alias :whole :ronde
  def blanche;  duree 2;    self end
  alias :half :blanche
  def noire;    duree 4;    self end
  alias :quarter :noire
  def croche;   duree 8;    self end
  alias :quaver :croche
  def dbcroche; duree 16;   self end
  alias :semiquaver :dbcroche
  def tpcroche; duree 32;   self end
  alias :demisemiquaver :tpcroche
  def qdcroche; duree 64;   self end
  def cqcroche; duree 128;  self end
  
  def pointee
    to_pointee
    self
  end
  alias :dotted :pointee
  
  # -------------------------------------------------------------------
  #   Méthodes de durée renvoyant le string de la note
  # -------------------------------------------------------------------
  def as_ronde;     duree 1;    self.to_s   end
  alias :as_whole :as_ronde
  def as_blanche;   duree 2;    self.to_s   end
  alias :as_half :as_blanche
  def as_noire;     duree 4;    self.to_s   end
  alias :as_quarter :as_noire
  def as_croche;    duree 8;    self.to_s   end
  alias :as_quaver :as_croche
  def as_dbcroche;  duree 16;   self.to_s   end
  alias :as_semiquaver :as_dbcroche
  def as_tpcroche;  duree 32;   self.to_s   end
  alias :as_demisemiquaver :as_tpcroche
  def as_qdcroche;  duree 64;   self.to_s   end
  def as_cqcroche;  duree 128;  self.to_s   end
  
  # -------------------------------------------------------------------
  #   Méthode de durée ne renvoyant pas l'instance ni la note string
  # -------------------------------------------------------------------
  def to_ronde;     duree 1     end
  alias :to_whole :to_ronde
  def to_blanche;   duree 2     end
  alias :to_half :to_blanche
  def to_noire;     duree 4     end
  alias :to_quarter :to_noire
  def to_croche nombre_demis = 1
    duree 8 * 2**(nombre_demis - 1) end
  alias :to_quaver :to_croche
  def to_dbcroche;  duree 16    end
  alias :to_semiquaver :to_dbcroche
  def to_tpcroche;  duree 32    end
  alias :to_demisemiquaver :to_tpcroche
  def to_qdcroche;  duree 64    end
  def to_cqcroche;  duree 128   end

  def to_dotted val = true
    return if @duration.to_s.end_with?('.')
    @duration = "#{@duration}."
  end
  alias :to_pointee :to_dotted

  
end