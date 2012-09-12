%{
-- Fichier lilypond réalisé par ruby2lily
-- https://github.com/PhilippePerret/ruby2lily.git

-- Ruby score:
	/Users/philippeperret/Sites/cgi-bin/lilypond/test/score/autre_essai.rb
%}

\version "2.16.0"

% Informations score
\header {
	title = "Essai Nos Habitudes"
	composer = "Philippe Perret"
}



% Score
{	<<\new PianoStaff <<
	\new Staff {
		\relative c'' {
			\clef "treble"
			\time 4/4
			\key g \major	\relative c''' { r4 b( a8 d, a' b~ b4) a4( a8 d, a'8 g~ g4) g4( fis8 b, fis' g~ g4) a4( a8 d, a'8 b~ b4) }
		}
	}
	\new Staff {
		\relative c' {
			\clef "bass"
			\time 4/4
			\key g \major	\relative c'' { \clef "treble" r4 b( a8 d, a' b~ b4) a4( a8 d, a'8 g~ g4) g4( fis8 b, fis' g~ g4) a4( a8 d, a'8 b~ b4) } \relative c''' { e4. d4. d g,1 fis2. fis8 fis a g8 }
		}
	}
>>
\new Staff {
	\relative c' {
		\clef "bass"
		\time 4/4
		\key g \major	
	}
}	>>
}
