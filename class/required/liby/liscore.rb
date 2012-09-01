# 
# Sous-class Liby::LIScore
# 
# Cette classe gère le score en tant qu'objet concret, c'est-à-dire le
# fichier lilypond qui sera porduit à partir du score ruby fourni.
# Elle n'est pas à confondre avec la classe Score qui gère le score en
# tant qu'abstraction.
# 
require 'liby'

class Liby::LIScore
  @@reffile = nil     # Référence au fichier score physique (lilypond)
  
  class << self
    
    # => Ajoute le code +code+ au fichier score lilypond
    # 
    # @note: Le code sera ajouté par `puts', donc on ne doit envoyer
    # que des lignes entières à cette méthode.
    # 
    def write code
      begin
        create if @@reffile.nil?
        @@reffile.puts code
        # debug "Code '#{code}' ajouté à #{@@reffile.inspect}"
        true
      rescue Exception => e
        raise "# [#{__FILE__}:#{__LINE__}] #{e.message}"
        false
      end
    end
    alias :add :write
    
    # => Crée le fichier lilypond et l'ouvre en écriture
    # ---------------------------------------------------
    def create
      path = Liby::path_lily_file
      Liby::fatal_error(:path_lily_undefined) if path.nil?
      begin
        delete
        @@reffile = File.open( path, 'a' )
      rescue Exception => e
        false
      else
        true
      end
    end
    
    def close
      return if @@reffile.nil?
      @@reffile.close
      @@reffile = nil
    end
    
    # => Détruit le fichier lilypond s'il existe
    def delete
      close unless @@reffile.nil?
      path = Liby::path_lily_file
      File.unlink path if File.exists? path
    end
  end
end