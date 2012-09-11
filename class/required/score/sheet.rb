# 
# Sous-class Score::Sheet
# 
# Pseudo-Singleton qui s'occupe de la partie affichage (feuille) du
# score courant
# 
require 'score'

class Score::Sheet
  class << self
    
    # => Méthode principale construisant le score
    def build
      score = Liby::LIScore
      score::create
      score::write entete   << "\n\n"
      score::write version  << "\n\n"
      score::write header   << "\n\n"
      score::write code     << "\n\n"  # code exemple (wiki)
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
      "%{" <<
      r<<  "-- Fichier lilypond réalisé par ruby2lily" <<
      r<<  "-- https://github.com/PhilippePerret/ruby2lily.git" <<
      r<<
      r<<  "-- Ruby score:" <<
      rt<< "#{Liby::path_ruby_score}" <<
      "\n%}"
    end
    def version
      "\\version \"#{lilypond_current_version}\""
    end
    
    def header
      r  = "\n"     # raccourci
      rt = "\n\t"   # idem
      h =   "% Informations score"
      h =  h << r << "\\header {"
      [ code_title, code_composer, code_arranger, code_opus, code_meter, 
        code_description
      ].each do |val|
        h = h << rt << val unless val.nil?
      end
      h = h << r << "}"
    end
    
    # =>  Retourne le code à écrire pour l'exemple de code qui 
    #     produit la partition courante (pour le wiki github)
    def code
      return "" if SCORE.code.nil? || SCORE.code.blank?
      code = SCORE.code.gsub(/\r/, '')
      lines = code.split("\n").collect{ |line|
        "\t\t\\line { \\typewriter { #{line} } }"
      }.join("\n")
      lines = lines.gsub(/"([^"]*)"/){ '“' << $1 << '”' }
      
      # Texte finalisé
      '\markup {' << \
      "\n\t\\column {" << \
      "\n\t\\null" << \
      "\n\t\\null" << \
      "\n\t\\line { \\typewriter { Extrait du code : } }" << \
      "\n\t\\line { \\typewriter { ----------------- } }" << \
      lines << \
      "\\null" << \
      "\\null" << \
      "\t}" << \
      "}"
    end
    
    # => Return le code complet de la partition
    def score
      markin  = ORCHESTRE.polyphonique? ? "\t<<"  : ""
      markout = ORCHESTRE.polyphonique? ? "\t>>"      : ""
      # Code retourné :
      "% Score" << "\n{" <<
      markin << ORCHESTRE::to_lilypond << markout << 
      "\n}"
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
    def code_arranger
      return nil if SCORE.arranger.nil? || SCORE.arranger == ""
      "arranger = \"#{SCORE.arranger}\""
    end
    # => Renvoie le code (hors tab) pour l'opus (si défini)
    def code_opus
      return nil if SCORE.opus.nil? || SCORE.opus == ""
      "opus = \"Op. #{SCORE.opus}\""
    end
    def code_meter
      return nil if SCORE.meter.nil? || SCORE.meter == ""
      "meter = \"#{SCORE.meter}\""
    end
    def code_description
      return nil if SCORE.description.nil? || SCORE.description == ""
      "description = \"#{SCORE.description}\""
    end
    
    # Retourne la version courante de lilypond
    def lilypond_current_version
      # @todo: plus tard, il faudra le lire dans un fichier
      "2.16.0"
    end
  end
end