%{
-- Fichier lilypond réalisé par ruby2lily
-- https://github.com/PhilippePerret/ruby2lily.git

-- Ruby score:
	/Users/philippeperret/Sites/cgi-bin/lilypond/test/score/simple.rb
%}

\version "2.16.0"

% Informations score
\header {
	title = "Partita"
	composer = "J.S. Bach"
}



% Score
{\new Staff {
	{
		\clef "treble"
		\time 4/4
		\tempo 4 = 120	\relative c'' { c a d }
	}
}
}
