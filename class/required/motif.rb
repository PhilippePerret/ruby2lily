# 
# CLass Motif
# 
class Motif
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  @motif = nil  # Le motif (String)
  def initialize params = nil
    case params.class.to_s
    when "String" then @motif = Liby::notes_ruby_to_notes_lily(params)
    else
      @motif = nil
    end
  end
  
  # =>  Return le motif en string avec l'ajout de la durée +duree+ si 
  #     elle est spécifiée
  def to_s params = nil
    return nil if @motif.nil?
    if params.class == Fixnum || params.class == String
      duree = params.to_s
      params = {}
      params[:duree] = duree
    elsif params.nil?
      params = {}
    end
    return @motif unless params.has_key?(:duree) && params[:duree]!=nil
    params[:duree] = params[:duree].to_s
    @motif.split(' ').collect{ |e| e + params[:duree]}.join(' ')
  end
  
  # -------------------------------------------------------------------
  #   Méthodes de transformation du motif
  # -------------------------------------------------------------------

  # => Retourne le motif baissé du nombre de +demitons+
  # @todo: plus tard, pourra modifier par degré, en restant dans la
  # gamme
  def moins demitons
    # La question qui se pose ici est : 
    # Est-ce vraiment le bon moyen de repérer les notes dans un
    # motif ?
    @motif.gsub(/\b([a-g](is|es)?(is|es)?)/){
      note = $1
      # debug "note dans moins : #{note}"
      LINote::new(note).moins(demitons, :tonalite => SCORE::key)
    }
  end
  # => Retourne le motif monté du nombre de +demitons+
  # @todo: plus tard, pourra modifier par degré, en restant dans la
  # gamme
  def plus demitons
    @motif.gsub(/\b([a-g](is|es)?(is|es)?)/){
      note = $1
      # debug "note dans plus : #{note}"
      LINote::new(note).plus(demitons, :tonalite => SCORE::key)
    }
  end
end