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
    
  end # / si tests

  # -------------------------------------------------------------------
  #   Classe
  # -------------------------------------------------------------------

  # => Retourne la marque « \relative c... » pour spécifier l'octave
  # 
  # @note: on compte sur la base de c' = do4
  # 
  def self.mark_relative octave
    case octave.class.to_s
    when "String"
      fatal_error(:bad_type_for_args, 
                  :method => "Score::mark_relative", :good => "Fixnum",
                  :bad    => octave.class.to_s)
    end
    octave ||= 4
    "\\relative #{mark_octave(octave)}"
  end
  
  # =>  Retourne la marque « c... » à ajouter à la marque relative
  #     d'octave
  # 
  # @note:  on compte sur la base de c' = do4 — base définie par
  #         LilyPond — donc il faut retirer 3 à l'octave spécifiée.
  # 
  def self.mark_octave octave
    octave ||= 4
    octave -= 3
    "c#{octave_as_llp(octave)}"
  end
  
  # => Retourne l'octave exprimée en virgules ou apostrophe
  # 
  def self.octave_as_llp oct
    return "" if oct == 0
    mk = oct > 0 ? "'" : ","
    mk.fois(oct.abs)
  end
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :title, :opus, :subtitle, :composer, :parolier, :key, 
              :time, :tempo, :base_tempo, :meter, :arranger, :description,
              :code
              
  @title      = nil   # Titre du morceau courant
  @opus       = nil   # Opus (sans "Op. ")
  @subtitle   = nil   # Sous-titre du morceau courant
  @composer   = nil   # Auteur (compositeur) du morceau courant
  @parolier   = nil   # Parolier du morceau courant (si paroles)
  @key        = nil   # Tonalité (une valeur de clé de LINote::TONALITES)
  @time       = nil   # Signature
  @tempo      = nil   # Tempo de référence
  @base_tempo = nil   # Durée de la note tempo de référence (durée llp)
  @meter      = nil   # Texte sous le titre à gauche de la page (peut
                      # être aussi défini par "@instrument")
  @arranger   = nil   # Arrangeur ou provenance
  @description= nil   # Description sous le titre
  @code       = nil   # Code sous l'header, ayant produit la partition
  
  def initialize params = nil
    
  end
  
  # === Méthode de définitions === #
  def set data
    check_data data
    @data.each { |prop, val| instance_variable_set("@#{prop}", val) }
    # Quelques valeurs par défaut
    Score::DEFAULT_VALUES.each do |prop, valdef|
      next unless instance_variable_get("@#{prop}").nil?
      instance_variable_set("@#{prop}", valdef)
    end
  end
  
  # => Check des data définies dans la partitions
  # Il peut exister deux sortes d'erreurs, dont certaines fatales
  def check_data data = nil

    @data = data || {}
    
    # Le titre doit être un string si fournie
    checkin_if_defined( :title, 'string' )
    
    # La key doit être correcte si fournie
    d = { :hash     => LINote::TONALITES, 
          :message  => Liby::ERRORS[:key_invalid] }
    checkin_if_defined( :key, 'is_key_of', d )
    
    # La signature doit être correcte si fournie
    if data.has_key?(:time) && data[:time] != nil
      data[:time] = '4/4' if data[:time] == 'C'
      if data[:time].gsub(/([0-9]+)\/([0-9]+)/,'') != ''
        fatal_error(:time_invalid, :bad => data[:time])
      end
    end
    
    
    # data a pu être rectifié
    @data = data
  end
  # => Check une seule donnée
  def checkin_if_defined cle, methods, params = nil
    return if !@data.has_key?( cle ) || @data[cle].nil?
    checkin cle, methods, params, fatal=true
  end

  def checkin cle, methods, params = nil, fatal = false
    methods = [methods] if methods.class == String
    params ||= {}
    data_var = params.merge( :var => "@#{cle.to_s}" ) 
    data_var = data_var.merge( :fatal => true ) if fatal
    # Toutes les méthodes doivent passer
    methods.each do |method|
      Checkif.send(method, @data[cle.to_sym], data_var)
    end
  end
end