%{
-- Fichier lilypond réalisé par ruby2lily
-- https://github.com/PhilippePerret/ruby2lily.git

-- Ruby score:
	/Users/philippeperret/Sites/cgi-bin/lilypond/test/score/exemple_read_me.rb
%}

\version "2.16.0"

% Informations score
\header {
	title = "Mon premier score lily2ruby"
	composer = "Phil"
}

% Score
{	<<\new Staff {
	\relative c'' {
		\clef "treble"
		\time 6/8
		\key g \major	\relative c'' { c4 c4 c4 e g c } \relative c'' { c4 c4 c4 e g c } \relative c'' { c4 c4 c4 e g c }
	}
}
\new PianoStaff <<
	\new Staff {
		\relative c'' {
			\clef "treble"
			\time 6/8
			\key g \major	\relative c'' { \relative c'' { <g c e>8  \relative c'' { <g c e>4  } \relative c'' { <g c e>4  } <g c e>8  }\relative c'' { <bis f a>8  \relative f'' { <bis f a>4  } \relative f'' { <bis f a>4  } <bis f a>8  }\relative c'' { <d g b>8  \relative g'' { <d g b>4  } \relative g'' { <d g b>4  } <d g b>8  } } \relative c'' { \relative c'' { <g c e>8  \relative c'' { <g c e>4  } \relative c'' { <g c e>4  } <g c e>8  }\relative c'' { <bis f a>8  \relative f'' { <bis f a>4  } \relative f'' { <bis f a>4  } <bis f a>8  }\relative c'' { <d g b>8  \relative g'' { <d g b>4  } \relative g'' { <d g b>4  } <d g b>8  } }
		}
	}
	\new Staff {
		\relative c' {
			\clef "bass"
			\time 6/8
			\key g \major	\relative c { \relative c { c8 c2 c8 }\relative c'' { f8 f2 f8 }\relative c'' { g8 g2 g8 } } \relative c { \relative c { c8 c2 c8 }\relative c'' { f8 f2 f8 }\relative c'' { g8 g2 g8 } }
		}
	}
>>
\new Staff {
	\relative c'' {
		\clef "treble"
		\time 6/8
		\key g \major	\relative c'' { c2. e g } \relative c'' { c2. e g }
	}
}	>>
}
