# 
# Tests pour la méthode :[] utilisable pour toutes les classes note
# 
require 'spec_helper'


describe "Méthode :[]" do
	# -------------------------------------------------------------------
	# 	Sur Motif
	# -------------------------------------------------------------------
  describe "sur les Motifs" do
    it "doit exister" do
      mo = Motif::new
			mo.should respond_to :[]
    end
		it "doit retourner un bon motif" do
		  pending "à implémenter"
		end
  end
	# -------------------------------------------------------------------
	# 	Sur les Notes
	# -------------------------------------------------------------------
  describe "sur les Notes" do
    it "doit exister" do
      no = Note::new
			no.should respond_to :[]
    end
		it "doit retourner une bonne Note" do
		  pending "à implémenter"
		end
  end
	# -------------------------------------------------------------------
	# 	Sur les Chord
	# -------------------------------------------------------------------
  describe "sur les Chords" do
		before(:each) do
		  @acc = Chord::new "a c e"
		end
    it "doit exister" do
			@acc.should respond_to :[]
    end
	  it "doit exister" do
	    @acc.should respond_to :[]
	  end
		it "doit retourner un accord" do
		  @acc[4,1].class.should == Chord
		end
		it "doit pouvoir recevoir octave, durée" do
			res = @acc[4, 8]
			res.to_s.should == "\\relative c'''' { <a c e>8 }"
		end
		it "doit pouvoir recevoir durée, octave si durée string" do
		  res = @acc["2", 1]
			res.to_s.should == "\\relative c' { <a c e>2 }"
		end
		it "doit pouvoir recevoir une unique valeur string (=> durée)" do
		  res = @acc["16"]
			res.to_s.should == "\\relative c''' { <a c e>16 }"
		end
		it "doit pouvoir recevoir une unique valeur octave (=> octave)" do
		  res = @acc[2]
			res.to_s.should == "\\relative c'' { <a c e> }"
		end
		it "doit pouvoir recevoir une valeur de durée-mot" do
		  res = @acc[blanche]
			res.to_s.should == "\\relative c''' { <a c e>2 }"
		end
		it "ne doit pas changer l'octave si nil" do
		  res = @acc[nil, 16]
			res.to_s.should == "\\relative c''' { <a c e>16 }"
		end
		it "doit pouvoir recevoir un hash" do
		  res = @acc[:duree => 8, :octave => -1]
			res.to_s.should == "\\relative c, { <a c e>8 }"
			res = @acc[:duration => 32, :octave => -2]
			res.to_s.should == "\\relative c,, { <a c e>32 }"
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
		  pending "à implémenter"
		end
  end

end