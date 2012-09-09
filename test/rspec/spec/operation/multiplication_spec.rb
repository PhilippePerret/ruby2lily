# 
# Tests de la multiplication
# 
# @rappel : la multiplication peut toucher toutes les classes de type
# 					note : String, Note, Chord, Motif
# 
require 'spec_helper'
require 'noteclass'
require 'string'
require 'note'
require 'linote'
require 'motif'
require 'chord'

describe "Multiplication" do
	# -------------------------------------------------------------------
	# Multiplication de Motifs
	# -------------------------------------------------------------------
  describe "de Motif" do
    it "doit retourner la bonne valeur quand x par 2" do
      mot = Motif::new "a c e"
			res = mot * 2
			res.class.should == Motif
			res.notes.should == "a c e a, c e"
			res.duration.should be_nil
			res.octave.should == 3
    end
    it "doit retourner la bonne valeur quand x par 3" do
      mot = Motif::new "a c e"
			res = mot * 3
			res.class.should == Motif
			res.notes.should == "a c e a, c e a, c e"
			res.duration.should be_nil
			res.octave.should == 3
    end
  end
	# -------------------------------------------------------------------
	#  Mutliplication de String
	# -------------------------------------------------------------------
	describe "de String" do
	  it "doit retourner la bonne valeur quand * 2" do
	  	res = "a" * 2
			res.class.should == Motif
			res.notes.should == "a a"
			res.to_s.should == "\\relative c''' { a a }"
	  end
		it "doit retourner une bonne valeur quand x 3" do
		  res = "b d fis" * 3
			res.class.should == Motif
			res.notes.should == "b d fis b, d fis b, d fis"
			res.to_s.should  == "\\relative c''' { b d fis b, d fis b, d fis }"
		end
		it "doit faire une multiplication simple si ce n'est pas un motif lilypond" do
			("str" * 2).should == "strstr"
			("-^ 8." * 2).should == "-^ 8.-^ 8."
		end
	end
	# -------------------------------------------------------------------
	#  Mutliplication de Note
	# -------------------------------------------------------------------
	describe "de Note" do
	  	
	end
	# -------------------------------------------------------------------
	#  Mutliplication de Chord
	# -------------------------------------------------------------------
	describe "de Chord" do
	  	
	end
end