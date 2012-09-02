%{
-- Fichier lilypond réalisé par ruby2lily
-- https://github.com/PhilippePerret/ruby2lily.git

-- Ruby score:
	/Users/philippeperret/Sites/cgi-bin/lilypond/test/score/simple_piano.rb
%}

\version "2.16.0"

% Informations score
\header {
	title = "Piano simple"
	composer = "Philippe Perret"
	meter = "Piano"
	description = "Une partition simple pour le piano, pour voir s'il s'écrira bien de façon 
générale
"
}

% Score
{\new PianoStaff <<
	\new Staff {
		\relative c'' {
			\clef "treble"
			\time 4/4
			b4 c d e <g b e f>8<g b e f><g b e f><g b e f>
		}
	}
	
	\new Staff {
		\relative c' {
			\clef "bass"
			\time 4/4
			g4 a b c <g, g'>8<g g'><g g'><g g'>
		}
	}
	
>>
}
