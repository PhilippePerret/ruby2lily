# 
# Pour tous les tests d'addition sur les :
# 	- String
# 	- Note
# 	- Motif
# 	- Accord
require 'spec_helper'
require 'string'
require 'note'
require 'linote'
require 'motif'
require 'chord'

# -------------------------------------------------------------------
# 	String
# -------------------------------------------------------------------
describe "Addition à String" do

  describe "String + String" do
    
  end
	describe "String + Note" do
	  
	end
	describe "String + Motif" do
	  
	end
	describe "String + Chord" do
	  
	end
end

# -------------------------------------------------------------------
# 	Note
# -------------------------------------------------------------------
describe "Addition à Note" do
	
  describe "Note + String" do
    
  end
	describe "Note + Note" do
	  
	end
	describe "Note + Motif" do
	  
	end
	describe "Note + Chord" do
	  
	end
end

# -------------------------------------------------------------------
# 	Motif
# -------------------------------------------------------------------
describe "Addition et Motif" do
	
  describe "Motif + String" do
    
  end
	describe "Motif + Note" do
	  
	end
	describe "Motif + Motif" do
	  
	end
	describe "Motif + Chord" do
	  
	end
end

# -------------------------------------------------------------------
# 	Chord
# -------------------------------------------------------------------
describe "Addition et Chord" do
	
  describe "Chord + String doit réussir" do
    it "doit réussir avec un accord simple et un string simple" do
      acc = Chord::new "a c e"
			str = "b"
			res = acc + str
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { <a c e> } \\relative c''' { b }"
    end
		it "doit réussir avec un accord dont on change l'octave et la durée" do
		  lam = Chord::new "a c e"
			str = "c'"
			res = lam[2,8] + str
			res.class.should == Motif
			res.to_s.should == "\\relative c'' { <a c e>8 } \\relative c' { c }"
		end
  end
	describe "Chord + Note" do
	  
	end
	describe "Chord + Motif" do
	  
	end
	describe "Chord + Chord" do
	  
	end
	describe "Chord + Autre" do
	  it "doit lever une erreur fatale" do
	    expect{@chord + 12}.to raise_error
	  end
	end
end