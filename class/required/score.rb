# 
# Classe Score (Partition)
# 
# C'est la classe principale de l'application, l'objet visé, c'est-à-dire
# une partition de musique imprimable et lisible.
# Pour parvenir à ce but, ruby2lily va utiliser un fichier ruby 
# définissant la partition en ruby, l'analyser et le mettre en forme
# pour être traduit en partition par lilypond.
# 

class Score
  
  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------

  # Toutes les valeurs par défaut pour les scores à imprimer
  DEFAULT_VALUES = {
    :title  => "Partition sans titre",
    :time   => '4/4'
  }
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  @path_ruby_score = nil  # Le path complet du fichier ruby de
                          # référence (le score en ruby)
  
  @title      = nil   # Titre du morceau courant
  @subtitle   = nil   # Sous-titre du morceau courant
  @composer   = nil   # Auteur (compositeur) du morceau courant
  @parolier   = nil   # Parolier du morceau courant (si paroles)
  @tune       = nil   # Tonalité
  @time       = nil   # Signature
  @tempo      = nil   # Tempo de référence
  @base_tempo = nil   # Durée de la note tempo de référence (noire)
  
  def initialize params = nil
    
  end
  
  # === Méthode de définitions === #
  def set data
    data.each { |prop, val| instance_variable_set("@#{prop}", val) }
    # Quelques valeurs par défaut
    Score::DEFAULT_VALUES.each do |prop, valdef|
      next unless instance_variable_get("@#{prop}").nil?
      instance_variable_set("@#{prop}", valdef)
    end
  end
  
  # === Méthodes pour le fichier lilypond === #
  
  # =>  Ultime méthode écrivant le fichier .ly pour lilypond et
  #     l'interprétant.
  def create_lilypond_file
    File.unlink path_lily_file if File.exists? path_lily_file
    File.open( path_lily_file, 'wb' ){ |f| f.write( to_ly ) }
  end
  
  # => Retourne le code lilypond du score courant
  def to_ly
    # pour le moment, juste pour essai :
    "% Un code fictif pour la partition ly\n" +
    "\\head {\n\ttitle = \"Juste un essai\"\n}\n" +
    "{c d e f g}"
  end

  # === Méthodes pour les paths === #
  
  def path_ruby_score
    @path_ruby_score || Liby::path_score_ruby
  end
  def path_lily_file
    @path_lily_file ||= path_of_extension( 'ly' )
  end
  def path_pdf_file
    @path_pdf_file ||= path_of_extension( 'pdf' )
  end
  # => Retourne le path courant avec l'extension +extension+
  # 
  # Cette méthode part du principe que tous les fichiers d'un même
  # score (partition) possède le même path, à la différence de 
  # l'extension près.
  def path_of_extension extension
    return nil if path_ruby_score.nil?
    folder  = File.dirname(@path_ruby_score)
    affixe  = File.basename(@path_ruby_score, '.rb')
    File.join(folder, "#{affixe}.#{extension}")
  end
end