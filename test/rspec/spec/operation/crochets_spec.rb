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
    it "doit exister" do
      acc = Chord::new
			acc.should respond_to :[]
    end
		it "doit retourner un bon accord" do
		  pending "à implémenter"
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