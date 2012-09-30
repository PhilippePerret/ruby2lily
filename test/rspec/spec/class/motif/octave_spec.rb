# 
# Tests bis de la classe Motif (sur les octaves)
# 
require 'spec_helper'
require 'motif'

describe Motif do
	before(:each) do
	  @mo = Motif::new "c"
	end
	describe "Définition de l'octave" do
	  it "doit définir correctement l'octave" do
	    @motif = Motif::new "c"
			@motif.octave.should == 4
			first_ln = @motif.explode.first
			first_ln.octave.should == 4
	  end
		it "Les LINotes doivent avoir la bonne octave avec suite normale" do
		  motif = Motif::new "c e g c", :octave => 0
			motif.octave.should == 0
			explosion = motif.explode 
			first_ln = explosion.first
			first_ln.octave.should == 0
			quatre = explosion[3]
			quatre.octave.should == 1
			quatre.delta.should == 0
		end
		it "Les LINotes doivent avoir la bonne octave avec un accord" do
		  motif = Motif::new "<c e g> c", :octave => 1
			motif.octave.should == 1
			explosion = motif.explode 
			first_ln = explosion.first
			first_ln.octave.should == 1
			quatre = explosion[3]
			# quatre.octave.should == 1 # Pas de changement d'octave
			quatre.octave.should 	== 1
			quatre.delta.should 	== 0
		end
	end
	describe "Changement d'octave" do
		describe "Au niveau du motif" do
		  it "<motif> doit répondre à :set_octave" do
		    @mo.should respond_to :set_octave
		  end
			it ":set_octave doit redéfinir l'octave du motif" do
			  motif = Motif::new "c", :octave => 1
				motif.octave.should == 1
				motif.set_octave 2
				motif.octave.should == 2
			end
		end
		describe "Update octave des LINotes" do
		  it "<motif> doit répondre à :update_octave_linotes" do
		    Motif::new.should respond_to :update_octave_linotes
		  end
		  it "pour une simple note" do
			  @motif = Motif::new "c"
		    @motif.octave.should == 4
				@motif.explode.first.octave.should == 4
				new_motif = @motif[2]
				new_motif.octave.should == 2
				@motif.octave.should == 4
				new_motif.explode.first.octave.should == 2
		  end
			it "changement d'octave avec note suivant accord" do
			  motif = Motif::new "<c e g> c", :octave => 1
				motif.set_octave 2
				explosion = motif.explode
				explosion.first.octave.should == 2
				explosion[3].octave.should == 2
			end
			it "changement d'octave avec accord suivant accord + note" do
			  motif = Motif::new "<c e g> <d fis g> a", :octave => 5
				motif.octave.should == 5
				explosion = motif.explode
				first 	= explosion.first
				quatre = explosion[3]
				sept   = explosion[6]
				first.octave.should == 5
				quatre.octave.should == 5
				sept.octave.should == 4
				# --- changement ---
				motif.set_octave 4
				motif.octave.should == 4
				first.octave.should == 4
				quatre.octave.should == 4
				sept.octave.should == 3
			end
			it "changement d'octave sur accords successifs" do
			  mo = Motif.new "<e g c>4 <e g c> <e g c> e"
				boum = mo.exploded
				un = boum[0]
				un.octave.should == 4
				un.note.should == "e"
				un.delta.should == 0
				trois = boum[2]
				trois.note.should == "c"
				trois.octave.should == 5
				trois.delta.should == 0
			  quatre = boum[3]
				quatre.octave.should == 4
				quatre.delta.should == 0
				sept = boum[6]
				sept.note.should == "e"
				sept.octave.should == 4
				sept.delta.should == 0
				dix = boum[9]
				dix.note.should == "e"
				dix.octave.should == 4
				dix.delta.should == 0
			end
		end
	end

end