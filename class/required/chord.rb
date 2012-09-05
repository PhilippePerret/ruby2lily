# 
# Class Chord (Accord)
# 
# Un accord est défini par une liste de notes, de la plus basse à la
# plus haute.
# L'intérêt pour le moment n'est pas évident, mais il le sera quand on
# développera les transpositions.
# 
require 'noteclass'
class Chord < NoteClass
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :chord, :octave, :duration
  
  @chord    = nil   # La liste array des notes, de la + basse à la + haute
  @octave   = nil   # L'octave (par défaut : 3)
  @duration = nil   # La durée (if any) de l'accord
  # Si des propriétés sont ajoutées, penser à les ajouter dans le
  # clonage de initialize (when "Chord")
  
  # Instanciation
  # 
  # @param  params    Peut être nil ou la liste des notes, de la plus
  #                   basse à la plus haute
  #                   Peut-être un hash (non utilisé encore)
  def initialize params = nil
    @octave   = 3
    @duration = nil
    @chord    = []
    case params.class.to_s
    when "Array"
      @chord = LINote::to_llp params
    when "String" 
      @chord = LINote::to_llp( params ).split(' ')
    when "Hash"
      @octave   = params[:octave] unless params[:octave].nil?
      @duration = params[:duration] # même si nil
      @chord    = params[:chord]
    when "Chord" # clone
      @octave   = params.octave
      @duration = params.duration
      @chord    = params.chord
    end
  end
  
  # =>  Retourne l'accord comme string. Si +duree+ est fournie, elle est
  #     ajoutée (sinon, ce sera la durée précédente)
  def to_s duree = nil
    return nil if @chord.empty?
    duree ||= @duration
    "#{LINote::mark_relative(@octave)} { #{self.to_acc(duree)} }"
  end
  alias :with_duree :to_s
  
  def as_motif params = nil
    params ||= {}
    params[:duree] = params if params.class == Fixnum
    Motif::new(
      :motif      => self.to_acc(params[:duree]), 
      :octave     => params[:octave] || @octave,
      :duration   => @duration
      )
  end
  
  def to_acc duree = nil
    duree ||= ""
    "<#{@chord.join(' ')}>#{duree.to_s}"
  end
  
  # => Ajoute une tierce à l'accord
  #     Soit l'accord accord : "c e"
  #     accord.tiercize => nouveau Chord contenant "c e g"
  #     accord.tiercize(2) => new Chord contenant "c e g b"
  # @todo: Implémenter Chord::tiercize
  # def tiercize nombre
  #   
  # end

  # => Retourne une nouvelle instance de l'accord (sauf si :new => false)
  #     avec les données définies dans les +params+
  # 
  # Pour la valeur de +params+ cf. `params_crochet_to_hash'
  # 
  # @return : la nouvelle instance créée ou self si :new => false
  # 
  # @todo: mettre ça dans le module operations MAIS ATTENTION :
  #         ci-dessous, on utilise self, qui doit pouvoir être interprété
  #         par toutes les classes de note (Note, Motif, Chord) pour
  #         prendre ses paramètres
  def []( *params)

    param1 = params[0]  # peut être nil
    param2 = params[1]  # peut être nil
    
    # Nouvelle instance (défaut) ou self
    if param1.class == Hash && param1.has_key?(:new) && param1[:new]
      new_inst = self
    else
      new_inst = self.class::new self
    end
    
    # Analyse paramètres entre crochets
    # ----------------------------------
    # @note: gère toutes les erreurs possibles
    params = self.class::params_crochet_to_hash params
    
    # Affectation des valeurs
    params.each do |property, value|
      new_inst.instance_variable_set("@#{property}", value)
    end
    
    # On retourne la nouvelle instance (ou self if any)
    new_inst
  end
  
end