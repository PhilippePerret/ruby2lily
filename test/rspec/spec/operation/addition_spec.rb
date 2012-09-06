# 
# Pour tous les tests d'addition sur les :
# 	- String
# 	- Note
# 	- Motif
# 	- Accord
require 'spec_helper'
require 'noteclass'
require 'string'
require 'note'
require 'linote'
require 'motif'
require 'chord'

# -------------------------------------------------------------------
# 	Méthode générale NoteClass#+
# -------------------------------------------------------------------
describe "NoteClass#+" do
  it "doit exister" do
    NoteClass::new.should respond_to :+
  end
end
# -------------------------------------------------------------------
# 	String
# -------------------------------------------------------------------
describe "Addition à String" do

  describe "String + String" do
    it "doit retourner un Motif contenant les notes" do
      res = "a" + "b"
			res.class.should == Motif
			res.notes.should == "a b"
			res = "a" + "bb" + "dois" + "la#"
			res.class.should == Motif
			res.notes.should == "a bes cis ais"
			res = "a'" + "bb"
			res.class.should == Motif
			res.notes.should == "a bes"
			res.octave.should == 3			# l'apostrophe est un delta, il doit
																	# être oublié quand il est en premier
																	# argument
    end
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
		it "doit renvoyer un motif conforme" do
		  n = Note::new "c"
			res = (n + "a'")
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { c a' }"
		end
		it "autre tests Notes + String" do
		  pending "à implémenter"
		end
  end
	describe "Note + Note" do
	  it "doit renvoyer un motif" do
	    no1 = Note::new "c"
			no2 = Note::new "d"
			res = no1 + no2
			res.class.should == Motif
			res.notes.should == "c d"
			res.octave.should == 3
			res.duration.should be_nil
	  end
		it "+ Note doit produire un nouveau motif" do
		  nut = ut
			nre = re
			nmi = mi
			res = (nut + nre + nmi)
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { c d e }"
		end
		it "avec différents octaves doit produire le bon résultat" do
		  nut = ut :octave => 1
			nre = re :octave => 2
			mo = nut + nre
			mo.class.should == Motif
			mo.to_s.should == "\\relative c' { c d' }"
		end
		
		it "autres tests Note + Note" do
			pending "à implémenter"
		end
	end
	describe "Note + Motif" do
		it "doit renvoyer un motif conforme" do
		  n = Note::new "c"
			m = Motif::new "e d"
			res = (n + m)
			res.class.should 				== Motif
			res.notes.class.should 	== String
			res.to_s.should == "\\relative c''' { c e d }"
		end
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
	describe "Généralités" do
	  it "doit répondre à :+" do
	    Chord::new("a c e").should respond_to :+
	  end
	end
  describe "Chord + String doit réussir" do
    it "doit réussir avec un accord simple et un string simple" do
      acc = Chord::new "a c e"
			str = "b"
			res = acc + str
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { <a c e> b }"
    end
		it "doit réussir avec un accord dont on change l'octave et la durée" do
		  lam = Chord::new "a c e"
			str = "c'"
			res = lam[2,"8"] + str
			res.class.should == Motif
			res.to_s.should == "\\relative c'' { <a c e>8 c'' }"
			
			res = lam[blanche, -2] + str
			res.class.should == Motif
			res.to_s.should == "\\relative c,, { <a c e>2 c'''''' }"
		end
  end
	describe "Chord + Note" do
	  it "Une note d oit pouvoir être ajoutée à un accord" do
	    pending "à implémenter"
	  end
	end
	describe "Chord + Motif" do
	  it "un motif d oit pouvoir être ajouté à un accord" do
	    pending "à implémenter"
	  end
	end
	describe "Chord + Chord" do
	  it "un accord d oit pouvoir être ajouté à un accord" do
	    pending "à implémenter"
	  end
	end
	describe "Chord + Autre" do
	  it "d oit lever une erreur fatale" do
	    expect{@chord + 12}.to raise_error
	  end
	end
end