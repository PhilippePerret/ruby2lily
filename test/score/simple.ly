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
		\tempo 4 = 120	<c e g> <c f a>
	}
}
}
