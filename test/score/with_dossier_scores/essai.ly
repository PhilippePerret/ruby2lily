%{
-- Fichier lilypond réalisé par ruby2lily
-- https://github.com/PhilippePerret/ruby2lily.git

-- Ruby score:
	/Users/philippeperret/Sites/cgi-bin/lilypond/test/score/with_dossier_scores/essai.rb
%}

\version "2.16.0"

% Informations score
\header {
	title = "Un essai avec dossier score"
	composer = "Phil"
}



% Score
{\new PianoStaff <<
	\new Staff {
		\relative c'' {
			\clef "treble"
			\time 4/4
			
		}
	}
	\new Staff {
		\relative c' {
			\clef "bass"
			\time 4/4
			a b c d
		}
	}
>>
}
