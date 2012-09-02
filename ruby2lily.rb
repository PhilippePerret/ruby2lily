#!/usr/bin/ruby
# encoding: UTF-8

# 
# Fichier principal de traitement des partitions écrites en ruby pour
# lilypond. C'est le module qui répond à la command `ruby2lily'
# 

DEBUG = false
def dbg txt
  return unless DEBUG
  puts "#{txt}"
end

# Définition préliminaire (initiliasation)
BASE_LILYPOND = File.dirname(__FILE__) unless defined? BASE_LILYPOND
require File.join(BASE_LILYPOND, 'module', 'init.rb')
require File.join(BASE_LILYPOND, 'module', 'handy_methods.rb')

# Analyse de la ligne de commande
# --------------------------------
dbg '----> Liby::analyze_command_line'
Liby::analyze_command_line

if Liby.commande?
  
  # -------------------------------------------------------------------
  #   Jouer une commande
  # -------------------------------------------------------------------
  
else
  
  # -------------------------------------------------------------------
  #   Lilipondage du fichier ruby
  # -------------------------------------------------------------------
  
  # Le score (défini par l'utilisateur et final)
  dbg '----> Instanciation de SCORE'
  SCORE     = Score::new  unless defined? SCORE # during tests
  # L'orchestre pour la partition
  dbg '----> Instanciation de ORCHESTRE'
  ORCHESTRE = Orchestre::new

  # Chargement du score
  # =====================
  dbg '----> load score file'
  load Liby::path_ruby_score

  # Composition de l'orchestre
  # ---------------------------
  dbg '----> ORCHESTRE::compose <orchestre>'
  ORCHESTRE::compose orchestre 
    # @note: `orchestre' est une méthode de la partition

  # Définition de la partition (Score)
  # -----------------------------------
  # @note: on reprend les données définies dans le score (si elles le
  # sont)
  dbg '----> SCORE::set <data>'
  SCORE::set(
    :title        => @title       || @titre,
    :subtitle     => @subtitle    || @soustitre,
    :composer     => @composer    || @compositeur,
    :author       => @author      || @parolier,
    :key          => @key         || @tune || @ton,
    :time         => @time        || @signature,
    :tempo        => @tempo,
    :base_tempo   => @base_tempo,
    :meter        => @meter       || @instrument,
    :arranger     => @arranger    || @arrangeur,
    :description  => @description
  )

  # Transformation du score ruby en score lilypond
  # -----------------------------------------------
  dbg '----> score'
  score # une méthode de la partition
  dbg '----> Liby::score_ruby_to_score_lilypond'
  Liby::score_ruby_to_score_lilypond

  # Génération du pdf
  # ------------------
  dbg '----> Liby::generate_pdf'
  Liby::generate_pdf

  # Message de fin
  # --------------
  dbg '----> Liby::end_conversion'
  Liby::end_conversion

end