%{
-- Fichier lilypond réalisé par ruby2lily
-- https://github.com/PhilippePerret/ruby2lily.git

-- Ruby score:
	/Users/philippeperret/Sites/cgi-bin/lilypond/test/score/simple.rb
%}

\version "2.7.38"

% Informations score
\header {
	title = "Partita"
	composer = "J.S. Bach"
}



% Score
{	<<\new Staff {
	\relative c'' {
		\clef "treble"
		\time 4/4
		\tempo 4 = 120	\relative c { a4 b c d e, f g a b c d e f, g a b }
	}
}
\new Staff {
	\relative c'' {
		\clef "treble"
		\time 4/4
		\tempo 4 = 120	\relative c { f g a b b c d e e, f g a a4 b c d }
	}
}	>>
}
