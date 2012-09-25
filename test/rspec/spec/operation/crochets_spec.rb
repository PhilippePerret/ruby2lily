# 
# Tests pour la méthode :[] utilisable pour toutes les classes note
# 
require 'spec_helper'


describe "Méthode :[]" do
	# -------------------------------------------------------------------
	# 	Sur les Notes
	# -------------------------------------------------------------------
  describe "sur les Notes" do
    it "doit exister" do
      no = Note::new
			no.should respond_to :[]
    end
		it "doit retourner une bonne Note" do
		  no = Note::new "c"
			no.class.should == Note
			res = no["8"]
			res.class.should == Note
			res.to_s.should == "\\relative c' { c8 }"
			no[2,"4"].to_s.should == "\\relative c, { c4 }"
		end
  end
	
	# -------------------------------------------------------------------
	# 	Sur les Motifs
	# -------------------------------------------------------------------
  describe "sur les Motifs" do
    it "doit exister" do
      mo = Motif::new
			mo.should respond_to :[]
    end
		it "doit retourner un bon motif" do
		  mo = Motif::new "c(\\< d e)\\!"
			puts "\n\n= MOTIF: #{mo.inspect}"
			mo_duree_8 = mo["8"]
			mo_duree_8.to_s.should == "\\relative c' { c8(\\< d e)\\! }"
			mo_octave_2 = mo[2]
			mo_octave_2.to_s.should == "\\relative c, { c(\\< d e)\\! }"
			mo_oct1_dur4 = mo["4", -1]
			mo_oct1_dur4.to_s.should == "\\relative c,,,, { c4(\\< d e)\\! }"
			mo_autre = mo[:duration => "2.", :octave => 6]
			mo_autre.to_s.should == "\\relative c''' { c2.(\\< d e)\\! }"
		end
		it "doit passer par la méthode :clef pour la définir" do
		  mo = Motif::new "c e f"
			mo.set_clef nil
			new_mo = mo[:octave => 3, :clef => 'g']
			iv_get(new_mo, :clef).should == "treble"
			new_mo = mo[:octave => 3, :clef => 'f']
			iv_get(new_mo, :clef).should == "bass"
			new_mo.to_s.should == "\\relative c { \\clef \"bass\" c e f }"
		end
  end
	# -------------------------------------------------------------------
	# 	Sur les Chords
	# -------------------------------------------------------------------
  describe "sur les Chords" do
		before(:each) do
		  @acc = Chord::new "a c e"
		end
    it "doit exister" do
			@acc.should respond_to :[]
    end
		it "doit retourner un accord" do
		  @acc[4,1].class.should == Chord
		end
		it "doit pouvoir recevoir octave, durée" do
			res = @acc[4, "8"]
			res.to_s.should == "\\relative c' { <a c e>8 }"
		end
		it "doit pouvoir recevoir durée, octave si durée string" do
		  res = @acc["2", 1]
			res.to_s.should == "\\relative c,, { <a c e>2 }"
		end
		it "doit pouvoir recevoir une unique valeur string (=> durée)" do
		  res = @acc["16"]
			res.to_s.should == "\\relative c' { <a c e>16 }"
		end
		it "doit pouvoir recevoir une unique valeur octave (=> octave)" do
		  res = @acc[2]
			res.to_s.should == "\\relative c, { <a c e> }"
		end
		it "doit pouvoir recevoir une valeur de durée-mot" do
		  res = @acc[blanche]
			res.to_s.should == "\\relative c' { <a c e>2 }"
		end
		it "ne doit pas changer l'octave si nil" do
		  res = @acc[nil, 16]
			res.to_s.should == "\\relative c' { <a c e>16 }"
		end
		it "doit pouvoir recevoir un hash" do
		  res = @acc[:duree => 8, :octave => -1]
			res.to_s.should == "\\relative c,,,, { <a c e>8 }"
			res = @acc[:duration => 32, :octave => -2]
			res.to_s.should == "\\relative c,,,,, { <a c e>32 }"
		end
		it "doit lever une erreur fatale si mauvaise valeur" do
			err = Liby::ERRORS[:bad_class_in_parameters_crochets]
		  expect{@acc[Chord::new(['c', 'e'])]}.to raise_error(SystemExit, err)
		end
  end
	# -------------------------------------------------------------------
	# 	Sur les LINotes
	# -------------------------------------------------------------------
  describe "sur les LINotes" do
    it "doit exister" do
      ln = LINote::new
			ln.should respond_to :[]
    end
		it "doit retourner une bonne linote" do
		  ln = LINote::new "cis", :octave => 3, :duration => "4."
			ln.to_s.should == "\\relative c { cis4. }"
			ln[1].to_s.should == "\\relative c,, { cis4. }"
		end
  end

end