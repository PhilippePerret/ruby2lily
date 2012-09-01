#!/usr/bin/ruby
# encoding: UTF-8

# 
# Fichier principal de traitement des partiions écrites en ruby pour
# lilypond
# 

# Définition préliminaire (initiliasation)
BASE_LILYPOND = File.dirname(__FILE__)
require File.join(BASE_LILYPOND, 'module', 'init.rb')
require File.join(BASE_LILYPOND, 'module', 'handy_methods.rb')

# Analyse de la ligne de commande
# --------------------------------
Liby::analyze_command_line

# Le score (défini par l'utilisateur et final)
SCORE     = Score::new
# L'orchestre pour la partition
ORCHESTRE = Orchestre::new

# Chargement du score
# =====================
load Liby::path_ruby_score

# Composition de l'orchestre
# ---------------------------
ORCHESTRE::compose @orchestre

# Définition de la partition (Score)
# -----------------------------------
# @note: on reprend les données définies dans le score (si elles le
# sont)
SCORE::set(
  :title      => @title       || @titre,
  :subtitle   => @subtitle    || @soustitre,
  :composer   => @composer    || @compositeur,
  :author     => @author      || @parolier,
  :tune       => @tune        || @ton,
  :time       => @time        || @signature,
  :tempo      => @tempo,
  :base_tempo => @base_tempo
)

# Transformation du score ruby en score lilypond
# -----------------------------------------------
Liby::score_ruby_to_score_lilypond



# Message de fin
# --------------
Liby::end_conversion