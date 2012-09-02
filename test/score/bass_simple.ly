%{
-- Fichier lilypond réalisé par ruby2lily
-- https://github.com/PhilippePerret/ruby2lily.git

-- Ruby score:
	/Users/philippeperret/Sites/cgi-bin/lilypond/test/score/bass_simple.rb
%}

\version "2.16.0"

% Informations score
\header {
	title = "Nos Habitudes"
	composer = "Phil"
	arranger = "Phil"
	meter = "Basse"
}

% Score
{\new Staff {
\relative c' {
	\clef "bass"
	\time 4/4
	\key g \major
	\tempo 4 = 100
g4 r8 g g4 r8 g | fis4 r8 fis fis4 r8 fis | e4 r8 e e4 r8 e | d4 r8 d d4 r8 d | r8 g b g( ges f~) f2 r8 a16 a a8( f e d~) d1.
}
}

}
