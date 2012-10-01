# 
# Tests spécialisés de la méthode :to_lilypond de Instrument
# 
require 'spec_helper'
require 'instrument'

describe Instrument do
	before(:all) do
	  SCORE = Score::new unless defined? SCORE
		iv_set(SCORE, :key => nil)
		iv_set(SCORE, :bars => nil)
		ORCHESTRE = Orchestre::new unless defined? ORCHESTRE
	end
	
  describe ":to_lilypond" do
	
	  before(:each) do
	    @instru = Instrument::new( {} )
	  end
	
    # :to_lilypond
	  it "doit exister" do
	    @instru.should respond_to :to_lilypond
	  end
		it "doit retourner un code valide" do
		  score = @instru.to_lilypond
			score.class.should == String
			score.should == 
				"\\new Staff {\n\t\\relative c' {" \
				<< "\n\t\t\\clef \"treble\"" \
				<< "\n\t\t\\time 4/4\n\t\t" \
				<< "\n\t}\n}"
			suite = "c d e f g a b c"
			@instru << suite
			@instru.to_lilypond.should == 
				"\\new Staff {\n\t\\relative c' {" \
				<< "\n\t\t\\clef \"treble\"" \
				<< "\n\t\t\\time 4/4\n\t\t" \
				<< "\\relative c' { #{suite} }" \
				<<"\n\t}\n}"
			# @note: des tests plus poussés sont effectués par le biais
			# des partitions.
		end

		it "doit régler le bon octave avec un premier motif le définissant" do
			motif = Motif::new "c d e f", :octave => 5
		  @instru << motif
			@instru.to_lilypond.should == 
				"\\new Staff {\n\t\\relative c'' {" \
				<< "\n\t\t\\clef \"treble\"" \
				<< "\n\t\t\\time 4/4\n\t\t" \
				<< "\\relative c'' { c d e f }" \
				<<"\n\t}\n}"
		end
		it "doit régler le bon octave sur différents motifs" do
		  motif_oct4 = Motif::new "c d e f", :octave => 4
			motif_oct5 = Motif::new "g a b c", :octave => 5
			motif_oct6 = Motif::new "c e g c", :octave => 6
			SCORE.bars 2 => "||"
		  @instru << motif_oct4
		  @instru << motif_oct5
		  @instru << motif_oct6
			@instru.to_lilypond.should == 
				"\\new Staff {\n\t\\relative c' {" \
				<< "\n\t\t\\clef \"treble\"" \
				<< "\n\t\t\\time 4/4\n\t\t" \
				<< "\\relative c' { c d e f \\bar \"||\" } \\relative c'' { g a b c } \\relative c''' { c e g c }" \
				<<"\n\t}\n}"
		end
  end
end