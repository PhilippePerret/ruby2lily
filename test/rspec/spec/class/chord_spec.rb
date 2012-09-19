# 
# Tests de la classe Chord (Accord)
# 
require 'spec_helper'
require 'chord'

SCORE = Score::new unless defined? SCORE

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
			@c.octave.should == 4
		end
		it "avec argument hash doit être valide" do
		  @c = Chord::new :notes => ["a", "cis", "e"], :octave => 2
			@c.notes.should == ["a", "cis", "e"]
			@c.octave.should == 2
		end
		it "argument :duree doit être remplacé par :duration" do
		  acc = Chord::new :notes => "a b c", :duree => "4."
			iv_get(acc, :duration).should == "4."
		end
		
		it "doit répondre à :notes_ascendantes?" do
		  acc = Chord::new "a c e"
			acc.should respond_to :notes_ascendantes?
		end
		it ":notes_ascendantes? doit renvoyer la bonne valeur" do
		  # testé avec la méthodes ci-dessous
		end
		[
			["a c e", true],
			["a c, e", false],
			["c g e", false],
			["c g' e'", true],
			["c g'' e'''", true]
		].each do |d|
			suite, valide = d
			it "L'instanciation avec «#{suite}» doit être #{valide ? 'valide' : 'invalide'}" do
			  # Par exemple "a c," n'est pas valide
				if valide
					expect{Chord::new :notes => suite}.not_to raise_error
				else
					err = detemp(Liby::ERRORS[:bad_args_for_chord], 
						:chord => suite,
						:error => "les notes doivent être ascendantes")
					expect{Chord::new :notes => suite}.to raise_error(SystemExit, err)
				end
			end
		end
  end
	describe "L'instance" do
	  before(:each) do
	    @chord = Chord::new
	  end
	
		# :[]
		# Testé dans spec/operations/crochets_spec.rb
		
		it "doit répondre à :set_params (par noteclass)" do
		  @chord.should respond_to :set_params
		end
		it "doit lever une erreur fatale en cas de mauvais octave" do
		  expect{Chord::new("a c e", :octave => 11)}.to raise_error
		end
		it "doit lever une erreur fatale en cas de mauvaise durée" do
		  expect{Chord::new("a c e", :duree => 3)}.to raise_error
		end
		# :clone
		it "doit répondre à :clone" do
		  @chord.should respond_to :clone
		end
		it ":clone doit renvoyer un vrai clone" do
		  acc1 = Chord::new :notes => "a c e", :duree => "8.", :octave => 4
			acc2 = acc1.clone
			iv_set(acc1, :notes => %w(c e g), :duration => "4")
			acc1.to_acc.should == "<c e g>4"
			acc2.to_acc.should == "<a c e>8."
		end
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
			@c.to_s(4).should == "\\relative c' { <c e g>4 }"
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
															:duration => nil, :octave => 4}
			notes = "c e g"
			acc = Chord::new :notes => notes, :octave => 5, :duration => "4."
			acc.to_hash.should == { :notes => notes.split(' '), 
															:duration => "4.", :octave => 5}
		end
		# :as_motif
		it "doit répondre à :as_motif" do
		  @chord.should respond_to :as_motif
		end
		it ":as_motif doit renvoyer la bonne valeur" do
			chord = Chord::new(:notes => ['a', 'c', 'e'], :octave => -1)
		  mo = chord.as_motif
			mo.class.should == Motif
			mo.to_s.should == "\\relative c,,,, { <a c e> }"
			iv_set(chord, :duration => 8)
			mo = chord.as_motif
			(mo.notes == "<a c e>8" ).should be_false
			mo.notes.should == "<a c e>"
			# puts "mo: #{mo.inspect}"
			mo.to_s.should == "\\relative c,,,, { <a c e>8 }"
		end
		
		# :with_duree
		it "doit répondre à :with_duree" do
		  @chord.should respond_to :with_duree
		end
		it ":with_duree doit renvoyer la bonne valeur" do
			@c = Chord::new "c e g"
			@c.with_duree(4).should == "\\relative c' { <c e g>4 }"
		end
		
		# :renversement / renverse
		it "doit répondre à :renversement et :renverse" do
		  @chord.should respond_to :renversement
			@chord.should respond_to :renverse
		end
		it ":renverse doit produire un renversement de l'accord" do
		  acc = Chord::new "c e g"
			renv1 = acc.renverse
			acc.object_id.should_not == renv1.object_id
			renv1.to_acc.should == "<e g c>"
			acc.to_acc.should 	== "<c e g>"
			acc.renverse(2).to_acc.should == "<g c e>"
			acc.to_acc.should == "<c e g>"
		end
		it ":renversement doit définir le bon octave" do
		  acc = Chord::new "c d fis"
			acc.renverse.to_acc.should == "<d fis c'>"
		end
		it ":renversement doit supprimer le delta de la nouvelle première note" do
		  acc = Chord::new "c e' g"
			acc.renverse.to_acc.should_not == "<e' g c>"
			acc.renverse.to_acc.should == "<e g c>"
			acc = Chord::new "c e'' g'"
			newacc = acc.renverse
			newacc.to_acc.should == "<e g' c>"
			newacc = newacc.renverse
			newacc.to_acc.should == "<g c e>"
		end
		it ":renversement doit remettre un delta supprimé" do
		  acc = Chord::new "c g' b"
			newacc = acc.renverse
			newacc.to_acc.should == "<g b c>"
			newacc2 = newacc.renverse
			newacc2.to_acc.should == "<b c g'>"
		end
		it "L'octave du renversement doit être le plus proche possible" do
		  acc = Chord::new 'c e g', :octave => 4
			puts "\nACC: #{acc.inspect}"
		end
		# :move / :degre
		it "doit répondre à :move / :to_degre" do
		  @chord.should respond_to :move
			@chord.should respond_to :to_degre
		end
		it ":to_degre (:move) doit renvoyer le bon accord" do
			acc = Chord::new "c e g"
		  iv_set(SCORE, :key => "C")
			acc.to_degre(2).to_acc.should == "<d f a>"
		  iv_set(SCORE, :key => "G")
			acc.to_degre(2).to_acc.should == "<d fis a>"
		  iv_set(SCORE, :key => "E")
			acc.to_degre(2).to_acc.should == "<dis fis a>"
		  iv_set(SCORE, :key => "Ab")
			acc.to_degre(2).to_acc.should == "<des f aes>"
		end
		
		it "deux accords doivent s'enchaîner correctement" do
		  acc1 = Chord::new "c e g", :octave => 4
			acc2 = Chord::new "c f a", :octave => 4
			riff = acc1 + acc2
			riff.to_s.should == "\\relative c' { <c e g> <c f a> }"
		end
	end # L'instance
end