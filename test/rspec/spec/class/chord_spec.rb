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
		end
  end
	describe "L'instance" do
	  before(:each) do
	    @chord = Chord::new
	  end
		it "doit répondre à :to_s" do
			@chord.should respond_to :to_s
		end
		it ":to_s doit renvoyer nil si l'accord n'est pas défini" do
			iv_set(@chord, :chord => [])
		  @chord.to_s.should be_nil
		end
		it ":to_s doit renvoyer la bonne valeur avec une durée spécifiée" do
			@c = Chord::new "c e g"
			@c.to_s(4).should == "<c e g>4"
		end
	end
end