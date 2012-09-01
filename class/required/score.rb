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

  unless defined?(Score::DEFAULT_VALUES)
    # Les préférences pour le score courant
    # (même si c'est une constante de classe)
    PREFERENCES = {
      :no_title => false,     # Mettre à true pour ne pas afficher le titre
    
      :end_end_end => nil     # juste pour sans virgule
    }
  
    # Toutes les valeurs par défaut pour les scores à imprimer
    DEFAULT_VALUES = {
      :title  => "Partition sans titre",
      :time   => '4/4'
    }
  end
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :title, :opus, :subtitle, :composer, :parolier, :tune, :time,
              :tempo, :base_tempo
              
  @title      = nil   # Titre du morceau courant
  @opus       = nil   # Opus (sans "Op. ")
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
end