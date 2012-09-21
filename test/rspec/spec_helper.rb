require 'fileutils'

BASE_RUBY2LILY = File.expand_path(File.join('..','..', File.dirname(__FILE__)))

RSpec.configure do |config|
  
  # Cf. la méthode éponyme dans ruby2lily.rb
  def load_class classe
    classe << ".rb" unless classe.end_with? ".rb"
    require File.join(BASE_RUBY2LILY, "class", "required", classe)
  end unless defined?(load_class)
  
  DIR_CLASS_LILYPOND = File.join(BASE_RUBY2LILY, 'class')
  $: << DIR_CLASS_LILYPOND
  $: << File.join(BASE_RUBY2LILY, 'class', 'required')
  $: << File.join(BASE_RUBY2LILY, 'class', 'optional')
  
  # Chargement des constantes
  require File.join(BASE_RUBY2LILY, 'module', 'constants.rb')
  # Chargement de toutes les librairies requises
  Dir["#{DIR_CLASS_LILYPOND}/required/**/*.rb"].each { |lib| require lib }
  # Chargement des méthodes pratiques et des fonctions de notes
  require File.join(BASE_RUBY2LILY, 'module', 'handy_methods.rb')
  require File.join(BASE_RUBY2LILY, 'module', 'note_methods.rb')

  $MODE_TEST = true
  
  config.before(:all){
    # À faire avant chaque describe
  }
  
  config.after(:all){
    # Après chaque 'describe', on détruit tous les dossiers tmp
    # En fait, je voulais qu'ils n'existent plus à la fin des tests,
    # pour éviter les problèmes d'autorisation.

  }
  
  # On commence, au cas où, à supprimer tous les pdf du dossier
  # test
  Dir["./*.pdf"].each { |pdf| File.unlink pdf }
  Dir["../score/*.pdf"].each { |pdf| File.unlink pdf }
  
  # => Initialise les paths principales liby (score ruby, score
  # lilypond et pdf)
  def init_all_paths_liby
		cv_set(Liby, :path_lily_file 	  => nil)
		cv_set(Liby, :path_pdf_file 	  => nil)
		cv_set(Liby, :path_ruby_score   => nil)			
		cv_set(Liby, :path_affixe_file  => nil)			
  end
  # => Initialise les options et paramètres
  def init_options_et_parametres
    cv_set(Liby, :options => nil)
    cv_set(Liby, :parameters => nil)
  end
  
  def iv_set(objet, hash)
    hash.each do |k, v|
      objet.instance_variable_set("@#{k}", v)
    end
  end
  def iv_get(objet, var)
    objet.instance_variable_get("@#{var}")
  end
  def cv_set(classe, hash)
    hash.each do |k, v|
      classe.send('class_variable_set', "@@#{k}", v )
    end
  end
  def cv_get(classe, var)
    classe.send('class_variable_get', "@@#{var}")
  end
  
  
  # === Pour simuler la ligne de commande === #
	
	def define_command_line_with_options
		path_score = File.join('test', 'score', 'partition_test.rb')
		ARGV.clear
		ARGV << path_score
		ARGV << "-fpng"
		ARGV << "--option voir"
	end
	def define_command_line argv
		argv = argv.split(' ') if argv.class == String
		ARGV.clear
		argv.each { |m| ARGV << m }
	end
	
  # Initialise les arguments (de la ligne de commande avec les valeurs
  # fournies)
	def init_argv_with array
	  array = [ array ] if array.class == String
	  ARGV.clear
	  array.each { |membre| ARGV << membre }
	end
end