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
  attr_reader :notes, :octave, :duration
  
  @notes    = nil   # La liste array des notes, de la + basse à la + haute
  @octave   = nil   # L'octave (par défaut : 3)
  @duration = nil   # La durée (if any) de l'accord
  # Si des propriétés sont ajoutées, penser à les ajouter dans le
  # clonage de initialize (when "Chord")
  
  # Instanciation
  # 
  # @param  notes     Peut être la liste des notes, sous forme de String
  #                   ou d'Array, ou un Hash contenant toutes les data
  # @param  params    Peut être nil ou la liste des notes, de la plus
  #                   basse à la plus haute, ou les données 
  #                   hors-notes pour définir l'accord
  #                   Peut-être un hash (non utilisé encore)
  # 
  def initialize notes = nil, params = nil
    @octave   = 3
    @duration = nil
    @notes    = []
    case notes.class.to_s
    when "String", "Array"
      @notes = LINote::to_llp( notes )
      # Dans le cas d'un String ou d'un Array, +params+ peut contenir
      # d'autres données
    when "Hash"
      params = notes
    when "Chord" # clonage
      params = notes.to_hash
    end
    
    unless params.nil?
      params[:duration] = params.delete(:duree) unless params[:duree].nil?
      params.each do |prop, value|
        instance_variable_set("@#{prop}", value)
      end
    end
    
    @duration = @duration.to_s unless @duration.nil?
    
    # On met les notes en Array (est-ce vraiment intéressant ?)
    @notes = @notes.split(' ') if @notes.class == String
    
  end
  
  # =>  Retourne un vrai clone de l'accord
  def clone
    Chord::new self.to_hash
  end
  
  # =>  Retourne l'accord comme string. Si +duree+ est fournie, elle est
  #     ajoutée (sinon, ce sera la durée précédente)
  # 
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
      :notes      => self.to_acc(""), # pour empêcher la durée 
      :octave     => params[:octave] || @octave,
      :duration   => duree
      )
  end
  
  # => Return un string sous forme d'accord (p.e. "<c e g>8")
  # 
  # @param  duree     La durée éventuelle à appliquer. Si non fournie
  #                   on utilise la :duration de l'accord
  # 
  # @note: on se sert de duree="" pour renvoyer un accord sans durée,
  # comme c'est le cas pour créer un motif.
  # 
  def to_acc duree = nil
    duree ||= @duration || ""
    "<#{@notes.join(' ')}>#{duree}"
  end
  
  # => Retourne les propriétés de l'accord sous forme de hash
  # 
  # @note: permet de faire un vrai clone, puisque toutes les références
  # sont court-circuitées
  def to_hash
    duree = @duration.nil? ? nil : @duration.to_s
    oct   = @octave.nil?   ? nil : @octave.to_i
    {
      :notes    => @notes.join(' ').split(' '), 
      :duration => duree, 
      :octave   => octave.to_i
    }
  end
  
  # =>  Return un renversement de l'accord
  # 
  # @note: par défaut, c'est le premier renversement qu'on retourne
  # 
  # @todo: il faut vérifier le changement d'octave
  def renverse renversement = 1
    chord = self.clone
    notes = chord.notes
    renversement.times { |i| notes << notes.delete_at(0) }
    chord.instance_variable_set("@notes", notes)
    chord
  end
  alias :renversement :renverse
  
  # =>  Return un déplacement de l'accord
  # 
  # Par exemple, si :
  #   l'accord est "c e g"
  #   la tonalité du morceau est G
  #   et qu'on le déplace de 1 degre, 
  # alors on obtient : "d fis g"
  def move degres
    new_acc = self.clone
    # @todo: implémenter ça :
    degres = (degres % 12) - 1 # -1 car degre 2 doit monter de 1 degré
    new_notes = new_acc.notes.collect{ |note|
      ind = LINote::GAMME_DIATONIQUE.index( note[0..0] )
      new_index = ( ind + degres ) % 7
      new_note  = LINote::GAMME_DIATONIQUE[new_index]
      new_note.with_alter_in_key SCORE.key
    }
    new_acc.instance_variable_set("@notes", new_notes)
    new_acc
  end
  alias :to_degre :move
  
  # => Ajoute une tierce à l'accord
  #     Soit l'accord accord : "c e"
  #     accord.tiercize => nouveau Chord contenant "c e g"
  #     accord.tiercize(2) => new Chord contenant "c e g b"
  # @todo: Implémenter Chord::tiercize
  # def tiercize nombre
  #   
  # end

end