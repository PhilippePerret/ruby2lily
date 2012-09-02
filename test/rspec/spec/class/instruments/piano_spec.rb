# 
# Tests de la class Piano < Instrument
# 
require 'spec_helper'
require 'instruments/piano'

describe Piano do
	def repond_a method
		@piano.should respond_to method
	end
	
	before(:all) do
	  SCORE = Score::new unless defined? SCORE
		ORCHESTRE = Orchestre::new unless defined? ORCHESTRE
	end
	
  # -------------------------------------------------------------------
	# Classe
	# -------------------------------------------------------------------
	describe "La classe" do
	  it "doit répondre à :new" do
	    Piano.should respond_to :new
	  end
		it ":new doit renvoyer un piano" do
		  Piano.new.class.should == Piano
		end
	end # / La classe
	
	# -------------------------------------------------------------------
	# 	L'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @piano = Piano::new
	  end
	end # / L'instance
	
	# -------------------------------------------------------------------
	# 	Les mains gauche et droite
	# -------------------------------------------------------------------
	describe "Mains gauche et droite" do
	  before(:each) do
	    @piano = Piano::new
	  end
		# Main droite
		it "doit répondre à :main_droite, :droite, :right_hand et :right" do
		  repond_a :main_droite
			repond_a :droite
			repond_a :right_hand
			repond_a :right
			repond_a :haut
			repond_a :high
		end
		it ":main_droite doit être de class Instrument" do
		  @piano.right_hand.class.should == Instrument
		end
		# Main gauche
		it "doit répondre à :main_gauche, :gauche, :left_hand et :left" do
		  repond_a :main_gauche
			repond_a :gauche
			repond_a :left_hand
			repond_a :left
			repond_a :bas
			repond_a :low
		end
		it ":main_gauche doit être de class Instrument" do
		  @piano.left_hand.class.should == Bass
		end
	end # / Mains gauche et droite
	
	# -------------------------------------------------------------------
	# 	Méthodes vers Lilypond
	# -------------------------------------------------------------------
	describe "Méthodes -> lilypond" do
	  before(:each) do
	    @piano = Piano::new
	  end
		it "doit répondre à :to_lilypond" do
		  repond_a :to_lilypond
		end
		it ":to_lilypond retourne un code correct" do
			iv_set(SCORE, :time => '3/8')
			code = <<-EOC
\\new PianoStaff <<
	\\new Staff {
		\\relative c'' {
			\\clef "treble"
			\\time 3/8
			
		}
	}
	
	\\new Staff {
		\\relative c' {
			\\clef "bass"
			\\time 3/8
			
		}
	}
	
>>
EOC
		  @piano.to_lilypond.strip.should == code.strip
			iv_set(SCORE, :time => nil)
		end
	end
end