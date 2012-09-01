# 
# Sous-class Score::Sheet
# 
# Pseudo-Singleton qui s'occupe de la partie affichage (feuille) du
# score courant
require 'score'

class Score::Sheet
  class << self
    
    # => Méthode principale construisant le score
    def build
      score = Liby::LIScore
      score::create
      score::write entete   + "\n\n"
      score::write version  + "\n\n"
      score::write header   + "\n\n"
      score::write self.score
      score::close
    end
    
    # -------------------------------------------------------------------
    #   Méthodes renvoyant le code pour le score Lilypond
    # -------------------------------------------------------------------

    # =>  Return le code de l'entête du fichier Lilypond, donnant 
    #     quelques informations
    def entete
      r   = "\n"
      rt  = "\n\t"
      "%{" + 
      r+  "-- Fichier lilypond réalisé par ruby2lily" +
      r+  "-- https://github.com/PhilippePerret/ruby2lily.git" +
      r+
      r+  "-- Ruby score:" +
      rt+ "#{Liby::path_ruby_score}" +
      "\n%}"
    end
    def version
      "\\version \"#{lilypond_current_version}\""
    end
    
    def header
      r  = "\n"     # raccourci
      rt = "\n\t"   # idem
      h =   "% Informations score"
      h +=  r+"\\header {"
      [code_title, code_composer, code_opus].each do |val|
        h += rt + val unless val.nil?
      end
      h += r + "}"
    end
    
    # => Return le code complet de la partition
    def score
      c = "% Score"
      c += "\n{"  # @todo: relative si nécessaire
      c += "\t<<" if ORCHESTRE.polyphonique?
      c += ORCHESTRE::as_lilypond_score
      c += "\t>>" if ORCHESTRE.polyphonique?
      c += "\n}"
    end
    
    # => Renvoie le code (hors tabulation) pour le titre
    def code_title
      return nil if Score::PREFERENCES[:no_title] || SCORE.title.nil? || SCORE.title == ""
      "title = \"#{SCORE.title}\""
    end
    # => Renvoie le code (hors tabulation) pour le compositeur
    def code_composer
      return nil if SCORE.composer.nil? || SCORE.composer == ""
      "composer = \"#{SCORE.composer}\""
    end
    # => Renvoie le code (hors tab) pour l'opus (si défini)
    def code_opus
      return nil if SCORE.opus.nil? || SCORE.opus == ""
      "opus = \"Op. #{SCORE.opus}\""
    end
    
    # Retourne la version courante de lilypond
    def lilypond_current_version
      # @todo: plus tard, il faudra le lire dans un fichier
      "2.16.0"
    end
  end
end