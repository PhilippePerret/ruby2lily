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
  
  require 'module/operations.rb' # normalement, toujours chargé
  include OperationsSurNotes
    # Définit +, * et []
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :notes, :octave, :duration
  
  @notes    = nil   # La liste array des notes, de la + basse à la + haute
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
    @notes    = []
    case params.class.to_s
    when "Array"
      @notes = LINote::to_llp params
    when "String" 
      @notes = LINote::to_llp( params ).split(' ')
    when "Hash"
      @octave   = params[:octave] unless params[:octave].nil?
      @duration = params[:duration] # même si nil
      @notes    = params[:notes]
    when "Chord" # clone
      @octave   = params.octave
      @duration = params.duration
      @notes    = params.notes
    end
  end
  
  # =>  Retourne l'accord comme string. Si +duree+ est fournie, elle est
  #     ajoutée (sinon, ce sera la durée précédente)
  def to_s duree = nil
    return nil if @notes.empty?
    duree ||= @duration
    "#{LINote::mark_relative(@octave)} { #{self.to_acc(duree)} }"
  end
  alias :with_duree :to_s
  
  def as_motif params = nil
    params ||= {}
    params[:duration] = params if params.class == Fixnum
    duree = params[:duration] || @duration
    Motif::new(
      :notes      => self.to_acc(params[:duree]), 
      :octave     => params[:octave] || @octave,
      :duration   => duree
      )
  end
  
  def to_acc duree = nil
    duree ||= ""
    "<#{@notes.join(' ')}>#{duree.to_s}"
  end
  
  # => Ajoute une tierce à l'accord
  #     Soit l'accord accord : "c e"
  #     accord.tiercize => nouveau Chord contenant "c e g"
  #     accord.tiercize(2) => new Chord contenant "c e g b"
  # @todo: Implémenter Chord::tiercize
  # def tiercize nombre
  #   
  # end

end