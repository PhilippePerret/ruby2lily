%{
-- Fichier lilypond réalisé par ruby2lily
-- https://github.com/PhilippePerret/ruby2lily.git

-- Ruby score:
	/Users/philippeperret/Sites/cgi-bin/lilypond/images/wiki/renv_et_move.rb
%}

\version "2.16.0"

% Informations score
\header {
	title = "Renversement et degrés"
}



% Score
{\new Staff {
	\relative c'' {
		\clef "treble"
		\time 4/4
		\relative c' { <c e g>1 <c f a>1 <d g b>1 <e g c>1 }
	}
}
}
