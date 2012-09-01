# 
# Tests de la classe Motif
# 
require 'spec_helper'
require 'motif'

describe Motif do
	before(:all) do
	  SCORE = Score::new unless defined? SCORE
	end
  describe "Instanciation" do
    it "sans argument doit laisser un motif vide" do
      @m = Motif::new
			iv_get(@m, :motif).should be_nil
    end
		it "avec argument string doit définir un motif" do
		  @m = Motif::new "a b c"
			iv_get(@m, :motif).should == "a b c"
		end
  end
	describe "L'instance" do
		before(:each) do
		  @m = Motif::new
		end
	  it "doit répondre à :to_s" do
	    @m.should respond_to :to_s
	  end
		it ":to_s doit renvoyer nil si le motif n'est pas défini" do
			iv_set(@m, :motif => nil)
		  @m.to_s.should be_nil
		end
		it ":to_s doit renvoyer le motif s'il est défini" do
		  iv_set(@m, :motif => "a b c")
			@m.to_s.should == "a b c"
		end
		it ":to_s doit renvoyer le motif avec une durée si elle est définie" do
		  iv_set(@m, :motif => "c d e")
			@m.to_s(1).should == "c1 d1 e1"
		end
	end
	
	describe "Transformation du motif" do
	  before(:each) do
	    @m = Motif::new "bb g f e,4 bb8"
	  end
		it "doit répondre à :moins" do
		  @m.should respond_to :moins
		end
		it ":moins doit donner le motif avec les demi-tons en moins" do
			iv_set(SCORE, :key => nil)
		  @m.moins(1).should == "a fis e ees,4 a8"
			@m.moins(2).should == "aes f ees d,4 aes8"
			iv_set(SCORE, :key => 'G')
		  @m.moins(1).should == "a fis e dis,4 a8"
			@m.moins(2).should == "gis f dis d,4 gis8"
		end
		it "doit répondre à :plus" do
		  @m.should respond_to :plus
		end
		it ":plus doit donner le motif supérieur" do
			iv_set(SCORE, :key => nil)
		  @m.plus(1).should == "b aes fis f,4 b8"
			@m.plus(2).should == "c a g fis,4 c8"
			iv_set(SCORE, :key => 'Bb')
		  @m.plus(1).should == "b aes ges f,4 b8"
			@m.plus(2).should == "c a g ges,4 c8"
		end
	
	end
end