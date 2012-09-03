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
  $: << File.join(BASE_LILYPOND, 'class', 'required')
  $: << File.join(BASE_LILYPOND, 'class', 'optional')

  require File.join(DIR_MOD_LILYPOND, 'constants.rb')

  Dir["#{DIR_CLASS_LILYPOND}/**/*.rb"].each { |lib| require lib }
  
  # Chargement des fonctions de notes (ut, re, etc.)
  require File.join(BASE_LILYPOND, 'module', 'note_methods.rb')
  
end