# 
# Initialisation de ruby2lily
# 
# Required
#     BASE_LILYPOND     Path au dossier Lilypond-ruby
# 

DIR_CLASS_LILYPOND  = File.join(BASE_LILYPOND, 'class')
DIR_MOD_LILYPOND    = File.join(BASE_LILYPOND, 'module')

$: << DIR_CLASS_LILYPOND
$: << File.join(BASE_LILYPOND, 'class', 'required')
$: << File.join(BASE_LILYPOND, 'class', 'optional')

require File.join(DIR_MOD_LILYPOND, 'constants.rb')

Dir["#{DIR_CLASS_LILYPOND}/**/*.rb"].each { |lib| require lib }
