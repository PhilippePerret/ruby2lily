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


# Permet de faire une classe globale en se servant des méthodes définies
# dans un fichier
# 
# @param  path
#         Le path du fichier contenant les méthodes
# @param  class_name
#         Le nom de la classe. Par défaut, c'est le nom du fichier qui
#         définit le nom de la classe : 
#           "path/to/mon_fichier.rb" => class MonFichier
# @param  as_static
#         Si true (par défaut), toutes les méthodes seront statiques
# 
# @note: cette méthode permet de gérer simplement les scores par
# instrument dans le dossier 'scores' à la racine
def make_global_class_from_file path, class_name = nil, as_static = true
  class_name ||= File.basename(path, '.rb').decamelize.camelize
  code = "class #{class_name}\n"
  code << "class << self\n" if as_static
  code << File.read(path)
  code << "\nend" if as_static
  code << "\nend"
  eval code
end
