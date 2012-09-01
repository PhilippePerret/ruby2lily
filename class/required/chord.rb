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
    case params.class.to_s
    when "Array"  then @chord = params
    when "String" then @chord = params.split(" ")
    else @chord = [] end
  end
  
  # =>  Retourne l'accord comme string. Si +duree+ est fournie, elle est
  #     ajoutée
  def to_s duree = nil
    return nil if @chord.empty?
    str = "<#{@chord.join(' ')}>"
    str += duree.to_s unless duree.nil?
    str
  end
end