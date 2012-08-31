# 
# Extensions de la class String
# 
class String
  
  RED     = 31
  GREEN   = 32
  BLUE    = 34
  YELLOW  = 43
  CYAN    = 36
  PURPLE  = 35
  BROWN   = 33
  GRAY    = 37
  EOC     = "\e[0m"              # Pour "End Of Color"
  
  def as_blue params = nil
    print_color BLUE, params
  end
  def as_green params = nil
    print_color GREEN, params
  end
  def as_red params = nil
    print_color RED, params
  end
  def as_yellow params = nil
    print_color YELLOW, params
  end
  
  def print_color code_couleur, params = nil
    params ||= {}
    style = "0"
    style += ";1" unless params[:bold].nil?
    style += ";4" unless params[:underline].nil?
    style += ";7" unless params[:reverse].nil?
    "\e[#{style};#{code_couleur}m#{self}#{EOC}"
  end
  
  # => Renvoie true si le string est vierge
  def blank?
    self == ""
  end
  # => True si le string est un entier
  def integer?
    self.gsub(/[0-9]/, '') == ""
  end
  
  # -------------------------------------------------------------------
  # Méthodes utiles pour classes, contrôleur <==> fichier
  # ----------------------------------------------------------------------
  def camelize # "bla_bla" => "BlaBla"
    self.split(/[^a-z0-9]/i).map{|w| w.capitalize}.join
  end
  def decamelize # "BlaBla" => "bla_bla"
    self.gsub(/^([A-Z])/){$1.downcase}.gsub(/([A-Z])/){'_' + $1}.downcase
  end

  
  #   Array et Hash
  #
  #   Méthodes pour gérer les "def-hash" et les "def-array", définitions
  #   de table array et hash sous forme de string-tableau
  # -------------------------------------------------------------------
  def to_hash to_sym = true
    hashstr_to_hash false, to_sym
  end
  def to_array to_sym = true
    hashstr_to_hash true, to_sym
  end
  def hashstr_to_hash as_array = false, to_sym = true
    tb = self.strip.gsub(/\t/, ' ').gsub(/  +/, ' ')
    hash = as_array ? [] : {}
    keys        = nil
    keys_type   = []
    nombre_cles = nil
    i_last_cle  = nil
    tb.split("\n").each do |line|
      line = line.strip
      next if line == "" || line.start_with?('#') || line.start_with?( '---' )
      dline = {}
      unless keys.nil?
        # Traitement d'une ligne de données
        line = line.split(' ')
        (0..i_last_cle).each do |ikey|
          key       = keys[ikey]
          real_val  = line[ikey]
          real_val =  if key != :id
                        real_val.nil? ? nil : real_val.vdefhash_to_real( keys_type[ikey] )
                      elsif real_val.integer?
                        real_val.to_i
                      else
                        real_val
                      end
          dline = dline.merge( key => real_val )
        end
      else
        # Définition des clés
        keys = line.split(' ').collect { |e| 
          e, type = e.split('/')
          e = e.downcase()
          keys_type << type       # Le type de la donnée, si définie
          e = e.to_sym if to_sym
          e
        }
        nombre_cles = keys.count
        i_last_cle  = nombre_cles - 1
        next
      end
      # Ajouter au hash ou à l'array
      if as_array
        hash << dline
      else
        k = to_sym ? dline[keys[0]].to_sym : dline[keys[0]]
        hash = hash.merge( k => dline)
      end
    end
    hash
  end

  # Renvoie la valeur "vraie" pour un def-hash
  # @note:  Le type de la donnée a pu être défini par cle/type en
  #         haut du tableau.
  #         Types :
  #           N   Renvoie un nombre entier
  #           S   Renvoie un string
  #           A   Renvoie un array (self doit être un str où les valeurs
  #               sont séparées par des virgules. Attention : pas 
  #               d'espace !)
  #           H   Renvoie un hash (self est évalué, donc doit être égal
  #               à quelque chose comme : ":id=>2,:titre=>'Mon titre'")
  #               Attention : pas d'espaces ! Les remplacer par des 
  #               insécables
  #               Attention : pas d'accolades non plus
  def vdefhash_to_real type = nil
    case type
    when nil  then
      case self
      when '1', 'oui', 'yes', 'y' then true
      when '0', 'non', 'no',  'n' then false
      when '-', 'null'            then nil
      else self
      end
    when 'N'  then self.to_i
    when 'S'  then self.to_s
    when 'A'  then self.split(',').collect{ |e| e.strip.gsub(/ /,' ') }
    when 'H'  then eval("{#{self.gsub(/ /,' ')}}")
    end
  end

end