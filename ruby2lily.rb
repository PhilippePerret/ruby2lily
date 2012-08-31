#!/usr/bin/ruby
# encoding: UTF-8

# 
# Fichier principal de traitement des partiions écrites en ruby pour
# lilypond
# 

# Définition préliminaire (initiliasation)
BASE_LILYPOND = File.dirname(__FILE__)
require File.join(BASE_LILYPOND, 'module', 'init.rb')

# Analyse de la ligne de commande
# --------------------------------
Liby::analyze_command_line

# Le score
SCORE     = Score::new
# L'orchestre pour la partition
# 
# @note: il sera défini par Liby ci-dessous
ORCHESTRE = Orchestre::new

# Transformation du score ruby en score lilypond
# -----------------------------------------------
Liby::score_ruby_to_score_lilypond

# Message de fin
# --------------
Liby::end_conversion