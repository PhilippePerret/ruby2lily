%{
-- Fichier lilypond réalisé par ruby2lily
-- https://github.com/PhilippePerret/ruby2lily.git

-- Ruby score:
	/Users/philippeperret/Sites/cgi-bin/lilypond/test/score/piano_complexe.rb
%}

\version "2.16.0"

% Informations score
\header {
	title = "Piano plus complexe"
	composer = "Phil"
	meter = "Piano"
}

% Score
{	<<\new Staff {
\new Staff {
	\relative c'' {
		\clef "treble"
		\time 4/4
		
	}
}

}
\new Staff {
\new PianoStaff <<
	\new Staff {
		\relative c'' {
			\clef "treble"
			\time 4/4
			<c e g>8<c e g>4 <c e g>4 <c e g>4 <c e g>8<d fis a>8<d fis a>4 <d fis a>4 <d fis a>4 <d fis a>8<c e g>8<c e g>4 <c e g>4 <c e g>4 <c e g>8<c e g>8<c e g>4 <c e g>4 <c e g>4 <c e g>8<d fis a>8<d fis a>4 <d fis a>4 <d fis a>4 <d fis a>8<c e g>8<c e g>4 <c e g>4 <c e g>4 <c e g>8
		}
	}
	
	\new Staff {
		\relative c' {
			\clef "bass"
			\time 4/4
			c4 c4 c4 c4 c4 c4 c4 c4 c4 c4 c4 c4 c c c c d d d d c c c c
		}
	}
	
>>
}	>>
}
