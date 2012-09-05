# 
# Classe Note
# 
# La classe d'une note
# 

require 'noteclass'

class Note < NoteClass
  
  unless defined?(Note::ANGLO_TO_ITAL)
    ANGLO_TO_ITAL = {'a' => 'la', 'b' => 'si', 'c' => 'do', 'd' => 'ré', 'e' => 'mi', 'f' => 'fa', 'g' => 'sol'}
    ITAL_TO_ANGLO = ANGLO_TO_ITAL.invert
  
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
    note, octave = [noteoct[0..0], noteoct[1..-1]]
    octave_positive = octave.start_with? "'"
    octave = octave.length
    octave = octave.to_i * -1 unless octave_positive
    [note, octave]
  end
  
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
  @itit       = nil       # La note, en notation italienne
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
    set(note) unless note.nil?
    params.each { |k,v| instance_variable_set("@#{k}", v)} unless params.nil?
  end
  
  def set valeur
    octave = nil
    if valeur == "r"
      @it   = @itit = nil
      @rest = true
    else
      if valeur.length > 1
        # Trois cas peuvent se présenter ici :
        #   1. La note est fournie avec une octave (p.e. "c,,")
        #   2. La note est fournie en italien (p.e. "si")
        #   3. La note est fournie en italien avec octave (p.e. "si''")
        if valeur.match(/[',]/).nil?
          # Valeur italienne simple
          @it = ITAL_TO_ANGLO[valeur.to_s]
        else
          # Valeur fournie avec octave
          unless valeur.match(/^(ut|do|re|mi|fa|sol|la|si)/).nil?
            valeur = valeur.sub(/^(ut|do|re|mi|fa|sol|la|si)/){
              ITAL_TO_ANGLO[$1.to_s]
            }
          end
          # Valeur anglaise avec octave
          @it, octave = Note::split_note_et_octave valeur
        end        
      else
        # Valeur anglaise simple (une seule lettre)
        @it   = valeur
      end
      @rest   = false
      @itit   = ANGLO_TO_ITAL[@it]
      @octave = octave unless octave.nil?
    end
  end
    
  def get
    @it
  end
  
  # => Return la note sous la forme d'un motif
  def as_motif
    Motif::new :motif => @it, :octave => @octave
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
  # => Définit la marque de l'octave pour l'affichage
  def mark_octave
    return "" if @octave.nil?
    LINote::octave_as_llp @octave
  end

  # => Renvoie la note telle qu'elle doit être affichée en lilipond
  # 
  # @note: pour n'obtenir que la note (sans octave), utiliser la
  # méthode :get
  def to_s # => to_lilipond
    note = rest? ? 'r' : "#{@it}#{mark_octave}"
    "#{note}#{mark_duration}"
    # @todo: il faudra ajouter ici tout ce qu'on peut faire pour
    # spécifier la note
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
    @duration = duree
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

  # -------------------------------------------------------------------
  #   Opérations sur les notes
  # -------------------------------------------------------------------
  
  # => Addition de notes
  # L'addition doit produire un motif contenant les deux notes 
  # additionnée (note : ensuite, ce sera donc le motif qui s'occupera
  # de la note)
  # 
  # @param  foo   Soit :
  #                 - Un string
  #                 - Une autre note
  #                 - Un motif
  def + foo
    case foo.class.to_s
    when "Note" then
      if @octave == foo.octave
        Motif::new :motif => "#{@it} #{foo.it}", :octave => @octave
      else
        moself  = Motif::new :motif => @it, :octave => @octave
        mofoo   = Motif::new :motif => foo.it, :octave => foo.octave
        moself + mofoo
      end
    when "String"
      note, octave = Note::split_note_et_octave foo
      self.as_motif + Motif::new( :motif => note, :octave => octave)
    when "Motif"
      self.as_motif + foo
    when "Chord"
      fatal_error(:cant_add_chord_to_note)
    else
      fatal_error(:cant_add_any_to_note, :classe => foo.class.to_s)
    end
  end
end