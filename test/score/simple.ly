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
	\relative c'' {
		\clef "treble"
		\time 6/8
		\tempo 4 = 120	bes4.-^\< f c fis fis\fff c gis' d<a c e>8 c8( b c d c b) a( g f e f g)
	}
}
}
