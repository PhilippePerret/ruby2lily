# 
# Tests de la classe Chord (Accord)
# 
require 'spec_helper'
require 'chord'

describe Chord do
  describe "Instanciation" do
    it "sans argument doit laisser un accord vide" do
      @c = Chord::new
			iv_get(@c, :notes).should be_empty
    end
		it "avec argument string doit être valide" do
		  @c = Chord::new "c e g"
			iv_get(@c, :notes).should == ["c", "e", "g"]
		end
		it "avec argument array doit être valide" do
		  @c = Chord::new ["c", "e", "g"]
			iv_get(@c, :notes).should == ["c", "e", "g"]
			@c.octave.should == 3
		end
		it "avec argument hash doit être valide" do
		  @c = Chord::new :notes => ["a", "cis", "e"], :octave => 2
			@c.notes.should == ["a", "cis", "e"]
			@c.octave.should == 2
		end
  end
	describe "L'instance" do
	  before(:each) do
	    @chord = Chord::new
	  end
	
		# :[]
		# Testé dans spec/operations/crochets_spec.rb
		
		# :to_s
		it "doit répondre à :to_s" do
			@chord.should respond_to :to_s
		end
		it ":to_s doit renvoyer nil si l'accord n'est pas défini" do
			iv_set(@chord, :notes => [])
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
		
		# :to_hash
		it "doit répondre à :to_hash" do
		  @chord.should respond_to :to_hash
		end
		it ":to_hash doit retourner le bon hash" do
			notes = "a c e"
		  acc = Chord::new notes
			acc.to_hash.should == { :notes => notes.split(' '), 
															:duration => nil, :octave => 3}
			notes = "c e g"
			acc = Chord::new :notes => notes, :octave => 4, :duration => "4."
			acc.to_hash.should == { :notes => notes.split(' '), 
															:duration => "4.", :octave => 4}
		end
		# :as_motif
		it "doit répondre à :as_motif" do
		  @chord.should respond_to :as_motif
		end
		it ":as_motif doit renvoyer la bonne valeur" do
			chord = Chord::new(:notes => ['a', 'c', 'e'], :octave => -1)
		  mo = chord.as_motif
			mo.class.should == Motif
			mo.to_s.should == "\\relative c, { <a c e> }"
			chord.instance_variable_set("@duration", 8)
			mo = chord.as_motif
			# puts "mo: #{mo.inspect}"
			mo.to_s.should == "\\relative c, { <a c e>8 }"
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