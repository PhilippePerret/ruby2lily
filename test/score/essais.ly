%{
-- Fichier lilypond réalisé par ruby2lily
-- https://github.com/PhilippePerret/ruby2lily.git

-- Ruby score:
	/Users/philippeperret/Sites/cgi-bin/lilypond/test/score/essais.rb
%}

\version "2.16.0"

% Informations score
\header {
	title = "Motif et méthode crochets"
}

\markup {
	\column {
	\null
	\null
	\line { \typewriter { Extrait du code : } }
	\line { \typewriter { ----------------- } }		\line { \typewriter { motif = Motif::new “a b c d” } }
		\line { \typewriter { motif_final = motif[1, “8.”].slure } }
		\line { \typewriter { JANE << motif_final } }\null\null	}}

% Score
{\new Staff {
	\relative c'' {
		\clef "treble"
		\time 4/4
		\relative c' { c }
	}
}
}
