# 
# Méthodes pratiques
# 

def debug txt
  STDOUT.write "#{txt}\n"
end

# =>  Raccourci pour afficher un message d'erreur fatale
# 
#     Ce message exite le programme
# @param  id_or_mess  Soit un message explicite, soit une clé de la
#                     constante ERRORS de Liby.
# @param  params      Les variables optionnelles à utiliser pour le
#                     message d'erreur
# 
def fatal_error id_or_mess, params = nil
  Liby::fatal_error id_or_mess, params
end

# =>  "Détemplatize" le texte +texte+ avec les variables définies dans
#     +params+, c'est-à-dire remplace les '#{variable}' dans +texte+
#     par les valeurs de params où la clé es 'variable'.
# 
# @note: trouver un autre nom plus explicite et aussi court
def detemp texte, params
  params.each do |var, val|
    texte = texte.gsub(/\#\{#{Regexp.escape(var.to_s)}\}/, val.to_s)
  end unless params.nil?
  texte
end
