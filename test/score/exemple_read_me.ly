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
	 title = "Mon premier score lily2ruby" composer = "Phil" 
 \header { } 

% Score 
{ 	<< \new Staff {
 	\relative c'' {
 	  	\clef "treble" 
	 	\time 6/8 
	 	\key g \major
	 	 c4 c4 c4  e g c c c  c4 c4 c4  e g c c c  c4 c4 c4  e g c c c 
	}
}

\new PianoStaff <<
	 \new Staff {
	 	\relative c'' {
	 	  	\clef "treble" 
		 	\time 6/8 
		 	\key g \major
		 	 <g c e> 8   <g c e> 4   <g c e> 4    <g c e> 8     <bis f a> 8   <bis f a> 4   <bis f a> 4    <bis f a> 8     <d g b> 8   <d g b> 4   <d g b> 4    <d g b> 8 
		}
	}
	
	 \new Staff {
	 	\relative c' {
	 	  	\clef "bass" 
		 	\time 6/8 
		 	\key g \major
		 	  
		}
	}
	
>>
\new Staff {
 	\relative c'' {
 	  	\clef "treble" 
	 	\time 6/8 
	 	\key g \major
	 	 c2. e g 
	}
}
 	>> 
}
