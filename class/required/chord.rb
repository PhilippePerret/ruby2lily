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
  
  # Instanciation
  # 
  # @param  params    Peut être nil ou la liste des notes, de la plus
  #                   basse à la plus haute
  #                   Peut-être un hash (non utilisé encore)
  def initialize params = nil
    @octave   = 3
    @duration = nil
    @chord    = case params.class.to_s
                when "Array"  
                  Liby::notes_ruby_to_notes_lily(params)
                when "String" 
                  Liby::notes_ruby_to_notes_lily(params.split(" "))
                when "Hash"
                  @octave   = params[:octave] unless params[:octave].nil?
                  @duration = params[:duration] # même si nil
                  params[:chord]
                else 
                  []
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
      :motif => self.to_acc(params[:duree]), 
      :octave => params[:octave] || @octave
      )
  end
  
  def to_acc duree = nil
    duree ||= ""
    "<#{@chord.join(' ')}>#{duree.to_s}"
  end

  # => Retourne une nouvelle instance de l'accord (sauf si :new => false)
  #     avec les données définies dans les +params+
  # 
  # Pour la valeur de +params+ cf. `params_crochet_to_hash'
  # 
  # @return : la nouvelle instance créée ou self si :new => false
  def []( *params)

    param1 = params[0]  # peut être nil
    param2 = params[1]  # peut être nil
    
    # Nouvelle instance (défaut) ou self
    if param1.class == Hash && param1.has_key?(:new) && param1[:new]
      new_inst = self
    else
      new_inst = Chord::new(self.chord)
    end
    
    # Analyse paramètres
    params = Chord::params_crochet_to_hash params
    
    # Affectation des valeurs
    params.each do |property, value|
      new_inst.instance_variable_set("@#{property}", value)
    end
    
    # On retourne la nouvelle instance (ou self if any)
    new_inst
  end
  
end