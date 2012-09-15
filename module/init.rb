# 
# Initialisation de ruby2lily
# 
# Required
#     BASE_LILYPOND     Path au dossier Lilypond-ruby
# 

unless defined? DIR_MOD_LILYPOND
  DIR_CLASS_LILYPOND  = File.join(BASE_LILYPOND, 'class') unless defined? DIR_CLASS_LILYPOND
  DIR_MOD_LILYPOND    = File.join(BASE_LILYPOND, 'module')

  $: << DIR_CLASS_LILYPOND
  dbg "Je mets #{DIR_CLASS_LILYPOND} en path par défaut"
  p = File.join(BASE_LILYPOND, 'class', 'required')
  $: << p
  dbg "Je mets #{p} en path par défaut"
  p = File.join(BASE_LILYPOND, 'class', 'optional')
  $: << p
  dbg "Je mets #{p} en path par défaut"

  require File.join(DIR_MOD_LILYPOND, 'constants.rb')

  Dir["#{DIR_CLASS_LILYPOND}/**/*.rb"].each do |lib| 

    # = débug =
    # puts "CHARGEMENT DE : #{lib}"
    # = /débug =

    require lib
  end
  
  # Chargement des fonctions de notes (ut, re, etc.)
  require File.join(BASE_LILYPOND, 'module', 'note_methods.rb')
  
end