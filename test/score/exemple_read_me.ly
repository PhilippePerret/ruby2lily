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
		\key g \major	c4 c4 c4  e g c c c  c4 c4 c4  e g c c c  c4 c4 c4  e g c c c
	}
}
\new PianoStaff <<
	\new Staff {
		\relative c'' {
			\clef "treble"
			\time 6/8
			\key g \major	<g c e>8  <g c e>4  <g c e>4   <g c e>8  <bis f a>8  <bis f a>4  <bis f a>4   <bis f a>8   <d g b>8  <d g b>4  <d g b>4   <d g b>8   <g c e>8  <g c e>4  <g c e>4   <g c e>8  <bis f a>8  <bis f a>4  <bis f a>4   <bis f a>8   <d g b>8  <d g b>4  <d g b>4   <d g b>8
		}
	}
	\new Staff {
		\relative c' {
			\clef "bass"
			\time 6/8
			\key g \major	c8 c2 c8 f8 f2 f8  g8 g2 g8  c8 c2 c8 f8 f2 f8  g8 g2 g8
		}
	}
>>
\new Staff {
	\relative c'' {
		\clef "treble"
		\time 6/8
		\key g \major	c2. e g \relative c'' { c2. e g }
	}
}	>>
}
