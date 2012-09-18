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

  unless defined?(Score) && defined?(Score::DEFAULT_VALUES)
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
  
  # => Retourne la durée d'une mesure de métrique +metrique+
  # 
  # @note: compter sur la base du fait qu'une noire vaut 1
  # 
  # @param  metrique    Le String de la métrique (p.e. "4/4"). Par défaut
  #                     une métrique de "4/4"
  def self.duree_absolue_mesure metrique
    metrique ||= "4/4"
    nombre, diviseur = metrique.split('/')
    valeur_diviseur       = 4.0 / diviseur.to_i
    valeur_diviseur * nombre.to_i
  end
  
  # -------------------------------------------------------------------
  #   Instance
  # -------------------------------------------------------------------
  attr_reader :title, :opus, :subtitle, :composer, :parolier, :key, 
              :time, :tempo, :base_tempo, :meter, :arranger, :description,
              :code,
              # Options modificatrices
              :from_mesure, :to_mesure, :displayed_instruments
              
  @title          = nil     # Titre du morceau courant
  @opus           = nil     # Opus (sans "Op. ")
  @subtitle       = nil     # Sous-titre du morceau courant
  @composer       = nil     # Auteur (compositeur) du morceau courant
  @parolier       = nil     # Parolier du morceau courant (si paroles)
  @key            = nil     # Tonalité (une valeur de clé de LINote::TONALITES)
  @time           = nil     # Signature (métrique)
  @tempo          = nil     # Tempo de référence
  @base_tempo     = nil     # Durée de la note tempo de référence (durée llp)
  @meter          = nil     # Texte sous le titre à gauche de la page (peut
                            # être aussi défini par "@instrument")
  @arranger       = nil     # Arrangeur ou provenance
  @description    = nil     # Description sous le titre
  @code           = nil     # Code sous l'header, ayant produit la partition
                       
  @from_mesure    = nil     # Mesure de départ pour l'affichage (défaut: nil)
  @to_mesure      = nil     # Mesure de fin pour l'affichage (défaut: nil)
  @displayed_instruments=nil  # Les instruments à afficher. Si nil: tous
  
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
  
  # =>  Méthode interne permettant de définir les mesures de départ et
  #     de fin (pour les extraits)
  # 
  # @param  params    Hash contenant :from et/ou :to avec les valeurs
  #                   que doivent prendre @from_mesure et @to_mesure
  def set_mesures params
    # @todo: ici, une vérification de la validité des informations
    @from_mesure  = params[:from] if params.has_key? :from
    @to_mesure    = params[:to]   if params.has_key? :to
  end
  # => Retourne la durée absolue d'une mesure complète dans la métrique
  # donnée du score (mise à 4/4 par défaut)
  # Cette valeur est calculée par rapport à une noire qui vaut 1.0
  def duree_absolue_mesure
    Score::duree_absolue_mesure( @time )
  end
end