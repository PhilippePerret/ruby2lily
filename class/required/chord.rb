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
  @chord = nil    # La liste array des notes, de la + basse à la + haute
  
  # Instanciation
  # 
  # @param  params    Peut être nil ou la liste des notes, de la plus
  #                   basse à la plus haute
  #                   Peut-être un hash (non utilisé encore)
  def initialize params = nil
    @chord = 
      case params.class.to_s
      when "Array"  
        Liby::notes_ruby_to_notes_lily(params)
      when "String" 
        Liby::notes_ruby_to_notes_lily(params.split(" "))
      else [] end
  end
  
  # =>  Retourne l'accord comme string. Si +duree+ est fournie, elle est
  #     ajoutée (sinon, ce sera la durée précédente)
  def to_s duree = nil
    return nil if @chord.empty?
    str = "<#{@chord.join(' ')}>"
    str = "#{str}#{duree.to_s}" unless duree.nil?
    "#{str.strip} "
  end
  alias :with_duree :to_s

  def []( params = nil)
    self.to_s params
  end
end