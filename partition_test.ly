%{
-- Fichier lilypond réalisé par ruby2lily
-- https://github.com/PhilippePerret/ruby2lily.git

-- Ruby score:
	/Users/philippeperret/Sites/cgi-bin/lilypond/partition_test.rb
%}

\version "2.16.0"

% Informations score
\header {
	title = "Partition sans titre"
}

% Score
{	<<\new Staff {
	\relative c'' {
		\clef "treble"
		\time 4/4
		
	}
}
\new PianoStaff <<
	\new Staff {
		\relative c'' {
			\clef "treble"
			\time 4/4
			
		}
	}
	\new Staff {
		\relative c' {
			\clef "bass"
			\time 4/4
			
		}
	}
>>
\new Staff {
	\relative c' {
		\clef "bass"
		\time 4/4
		
	}
}
\new Staff {
	\relative c'' {
		\clef "treble"
		\time 4/4
		
	}
}	>>
}
