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
    when "String" then @motif = params
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
    return @motif unless params.has_key?(:duree)
    @motif.split(' ').collect{ |e| e + params[:duree].to_s}.join(' ')
  end
end