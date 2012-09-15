require 'fileutils'

BASE_LILYPOND = File.expand_path(File.join('..','..', File.dirname(__FILE__)))

RSpec.configure do |config|
  
  # Cf. la méthode éponyme dans ruby2lily.rb
  def load_class classe
    classe << ".rb" unless classe.end_with? ".rb"
    require File.join(BASE_LILYPOND, "class", "required", classe)
  end unless defined?(load_class)
  
  DIR_CLASS_LILYPOND = File.join(BASE_LILYPOND, 'class')
  $: << DIR_CLASS_LILYPOND
  $: << File.join(BASE_LILYPOND, 'class', 'required')
  $: << File.join(BASE_LILYPOND, 'class', 'optional')
  
  # Chargement des constantes
  require File.join(BASE_LILYPOND, 'module', 'constants.rb')
  # Chargement de toutes les librairies requises
  Dir["#{DIR_CLASS_LILYPOND}/required/**/*.rb"].each { |lib| require lib }
  # Chargement des méthodes pratiques et des fonctions de notes
  require File.join(BASE_LILYPOND, 'module', 'handy_methods.rb')
  require File.join(BASE_LILYPOND, 'module', 'note_methods.rb')

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
end