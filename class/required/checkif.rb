# 
# Class Checkif
# 
# Permet de faire des checks de valeurs (simples pour le moment)
# 
# @requis
# 
#   Une méthode 'error' recevant comme argument l'erreur renvoyée
#   Une méthode 'fatal_error' recevant idem
# 
# @usage
# 
#   Checkif::<methode conditionnelle>( <valeur>[, <params>])
# 
#   où :
#     <methode conditionnelle> est la méthode correspondant à la 
#     condition que doit remplir la valeur <valeur>
#     <params> est un hash contenant des paramètres optionnels, à
#     commencer par 
#       :fatal => true/false  pour déterminer si l'erreur doit être
#                             fatale ou non.
#       :var    => <nom de la variable visée>
# 
# @exemple
# 
#     Checkif::string( "bonne valeur", :fatal => true, :var => "@titre")
# 
class Checkif
  unless defined? Checkif::ERRORS
    ERRORS = {
      :undefined      => "La valeur `\#{var}' doit être définie !",
      :not_a_string   => "\#{var} doit être une chaine de caractères !",
      :not_a_array    => "\#{var} doit être un array (liste) !",
      :not_a_hash     => "\#{var} doit être un hash (tableau associatif) !",
      :fin_fin_fin => ''
    }
  end
  
  class << self
    
    # -------------------------------------------------------------------
    #   Méthodes de test
    # -------------------------------------------------------------------
    # => Renvoie true si +valeur+ est défini.
    # @note: contrairement aux autres méthodes, il faut envoyer la
    # valeur dans un string, car si on veut savoir dans le programme
    # que la variable `ca` est définie, on ne peut pas appeler cette
    # méthode avec : Checkif::defined(ca), ce qui génèrerait une erreur
    # de variable non définie.
    def defined valeur, params = nil
      return true if eval("defined? #{valeur}")
      generate_error :undefined, params
    end
    def string valeur, params = nil
      return true if valeur.class == String
      generate_error :not_a_string, params
    end
    def array valeur, params = nil
      return true if valeur.class == Array
      generate_error :not_a_array, params
    end
    def hash valeur, params = nil     # @note: ça surclasse `hash' naturel
      return true if valeur.class == Hash
      generate_error :not_a_hash, params
    end
    # @todo: ajouter au besoin :
    #   - integer
    #   - float
    #   - greater_than
    #   - less_than
    #   - start_with
    #   - end_with
    #   - between
    
    # === Utilitaires ===
    def generate_error cle, params
      params ||= {}
      is_fatal = params.delete(:fatal)
      method = is_fatal ? 'raise_fatal' : 'raise_error'
      send(method, formate_error( cle, params ) )
      false
    end
    def formate_error cle, params
      err = Checkif::ERRORS[cle]
      params.each do |var, val|
        err = err.gsub(/#\{#{var}\}/, val)
      end unless params.nil?
      err
    end
    def raise_fatal mess_erreur
      if defined? fatal_error
        fatal_error( mess_erreur )
      else
        raise SystemExit, mess_erreur
      end
    end
    def raise_error mess_erreur
      if defined? error
        error( mess_erreur )
      else
        raise mess_erreur
      end
    end
  end
  
end