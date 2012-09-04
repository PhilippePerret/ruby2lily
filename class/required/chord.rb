# 
# Class Chord (Accord)
# 
# Un accord est défini par une liste de notes, de la plus basse à la
# plus haute.
# L'intérêt pour le moment n'est pas évident, mais il le sera quand on
# développera les transpositions.
# 
class Chord
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :chord, :octave
  
  @chord  = nil   # La liste array des notes, de la + basse à la + haute
  @octave = nil   # L'octave (par défaut : 3)
  # Instanciation
  # 
  # @param  params    Peut être nil ou la liste des notes, de la plus
  #                   basse à la plus haute
  #                   Peut-être un hash (non utilisé encore)
  def initialize params = nil
    @octave = 3
    @chord = 
      case params.class.to_s
      when "Array"  
        Liby::notes_ruby_to_notes_lily(params)
      when "String" 
        Liby::notes_ruby_to_notes_lily(params.split(" "))
      when "Hash"
        @octave = params[:octave] unless params[:octave].nil?
        params[:chord]
      else 
        []
      end
  end
  
  # =>  Retourne l'accord comme string. Si +duree+ est fournie, elle est
  #     ajoutée (sinon, ce sera la durée précédente)
  def to_s duree = nil
    return nil if @chord.empty?
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

  def []( params = nil)
    self.to_s params
  end
end