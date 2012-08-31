require 'fileutils'

BASE_LILYPOND = File.expand_path(File.join('..','..', File.dirname(__FILE__)))

RSpec.configure do |config|
  
  DIR_CLASS_LILYPOND = File.join(BASE_LILYPOND, 'class')
  $: << DIR_CLASS_LILYPOND
  $: << File.join(BASE_LILYPOND, 'class', 'required')
  $: << File.join(BASE_LILYPOND, 'class', 'optional')
  
  # Chargement des constantes
  require File.join(BASE_LILYPOND, 'module', 'constants.rb')
  # Chargement de toutes les librairies requises
  Dir["#{DIR_CLASS_LILYPOND}/required/**/*.rb"].each { |lib| require lib }
  
  config.after(:all){
    # Après chaque 'describe', on détruit tous les dossiers tmp
    # En fait, je voulais qu'ils n'existent plus à la fin des tests,
    # pour éviter les problèmes d'autorisation.

  }
  config.before(:all){
    # À faire avant chaque describe
  }
  
  # Pour afficher un message de débuggage
  def debug txt
    STDOUT.write "::débug:: #{txt}\n"
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