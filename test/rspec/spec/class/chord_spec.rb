# 
# Tests de la classe Chord (Accord)
# 
require 'spec_helper'
require 'chord'

describe Chord do
  describe "Instanciation" do
    it "sans argument doit laisser un accord vide" do
      @c = Chord::new
			iv_get(@c, :chord).should be_empty
    end
		it "avec argument string doit être valide" do
		  @c = Chord::new "c e g"
			iv_get(@c, :chord).should == ["c", "e", "g"]
		end
		it "avec argument array doit être valide" do
		  @c = Chord::new ["c", "e", "g"]
			iv_get(@c, :chord).should == ["c", "e", "g"]
			@c.octave.should == 3
		end
		it "avec argument hash doit être valide" do
		  @c = Chord::new :chord => ["a", "cis", "e"], :octave => 2
			@c.chord.should == ["a", "cis", "e"]
			@c.octave.should == 2
		end
  end
	describe "L'instance" do
	  before(:each) do
	    @chord = Chord::new
	  end
	
		# :[]
		it "doit répondre à :[]" do
		  @chord.should respond_to :[]
		end
		it ":[] doit renvoyer le string de l'accord de la durée voulue" do
		  @chord = Chord::new "a c e"
			@chord[8].should == "\\relative c''' { <a c e>8 }"
		end
		
		# :to_s
		it "doit répondre à :to_s" do
			@chord.should respond_to :to_s
		end
		it ":to_s doit renvoyer nil si l'accord n'est pas défini" do
			iv_set(@chord, :chord => [])
		  @chord.to_s.should be_nil
		end
		it ":to_s doit renvoyer la bonne valeur avec une durée spécifiée" do
			@c = Chord::new "c e g"
			@c.to_s(4).should == "\\relative c''' { <c e g>4 }"
		end
		
		# :to_acc
		it "doit répondre à :to_acc" do
		  @chord.should respond_to :to_acc
		end
		it ":to_acc doit renvoyer la bonne valeur" do
		  chord = Chord::new "a c e"
			chord.to_acc.should == "<a c e>"
			chord.to_acc(4).should == "<a c e>4"
		end
		# :as_motif
		it "doit répondre à :as_motif" do
		  @chord.should respond_to :as_motif
		end
		it ":as_motif doit renvoyer la bonne valeur" do
			chord = Chord::new(:chord => ['a', 'c', 'e'], :octave => -1)
		  mo = chord.as_motif
			mo.class.should == Motif
			mo.to_s.should == "\\relative c, { <a c e> }"
		end
		
		# :with_duree
		it "doit répondre à :with_duree" do
		  @chord.should respond_to :with_duree
		end
		it ":with_duree doit renvoyer la bonne valeur" do
			@c = Chord::new "c e g"
			@c.with_duree(4).should == "\\relative c''' { <c e g>4 }"
		end
	end
end