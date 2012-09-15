#!/usr/bin/ruby
# encoding: UTF-8

# 
# Fichier principal de traitement des partitions écrites en ruby pour
# lilypond. C'est le module qui répond à la command `ruby2lily'
# 

DEBUG = false unless defined? DEBUG
def dbg txt
  return unless DEBUG
  # puts "<div>#{txt}</div>"
  STDOUT.write "<div>#{txt}</div>"
end

# Chargement d'une classe avec son path complet
# 
# J'ai dû initier cette méthode parce qu'il était impossible de lancer
# la fabrication d'une partition hors du path du dossier. La classe 
# "score" (et seulement celle-là apparemment) ne se chargeait pas. 
# Pourtant, les path par défaut étaient correctement définis. Je n'ai
# toujours pas compris ce qui se passait…
def load_class classe
  dbg "Chargement de la classe: #{classe}"
  classe << ".rb" unless classe.end_with? ".rb"
  require File.join(BASE_LILYPOND, "class", "required", classe)
end unless defined?(load_class)

dbg "--> ruby2lily"

# Définition préliminaire (initiliasation)
BASE_LILYPOND = File.dirname(__FILE__) unless defined? BASE_LILYPOND

dbg "BASE_LILYPOND: #{BASE_LILYPOND}"

# Dir.chdir(BASE_LILYPOND)
p = File.expand_path(".")

require File.join(BASE_LILYPOND, 'module', 'init.rb')
require File.join(BASE_LILYPOND, 'module', 'handy_methods.rb')

# Analyse de la ligne de commande
# --------------------------------
dbg '----> Liby::analyze_command_line'
Liby::analyze_command_line

if Liby.command?
  
  # -------------------------------------------------------------------
  #   Jouer la commande
  # -------------------------------------------------------------------
  Liby::run_command
  
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
  
  # Chargement des fichiers séparés (si dossier 'scores' existe)
  # ================================
  Liby::load_scores_files

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
    :description  => @description,
    :code         => @code  # development only
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