# 
# Tests de la classe Motif
# 
require 'spec_helper'
require 'motif'

describe Motif do
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
end