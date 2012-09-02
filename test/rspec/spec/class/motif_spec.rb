# 
# Tests de la classe Motif
# 
require 'spec_helper'
require 'motif'

describe Motif do
	def repond_a method
		@m.should respond_to method
	end
	
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
		
		# :to_s
	  it "doit répondre à :to_s" do repond_a :to_s end
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
	
		# :change_objet_ou_new_instance
		it "doit répondre à :change_objet_ou_new_instance" do
		  repond_a :change_objet_ou_new_instance
		end
		it ":change_objet_ou_new_instance doit modifier l'objet si demandé" do
			@motif = Motif::new "a b c"
		  @new = @motif.change_objet_ou_new_instance "c b a", nil, false
			@new.to_s.should == @motif.to_s
		end
		it ":change_objet_ou_new_instance doit créer un nouvel objet si demandé" do
			@motif = Motif::new "a b c"
		  @new = @motif.change_objet_ou_new_instance "c b a", nil, true
			@new.to_s.should_not == @motif.to_s
		end
		
		# :set_new_if_not_defined
		it "doit répondre à :set_new_if_not_defined" do
		  repond_a :set_new_if_not_defined
		end
		it ":set_new_if_not_defined doit définir la valeur de params[:new]" do
		  params = {}
			@m.set_new_if_not_defined params, false
			params[:new].should === false
		  params = {}
			@m.set_new_if_not_defined params, true
			params[:new].should === true
		  params = {:new => true}
			@m.set_new_if_not_defined params, false
			params[:new].should === true
		  params = {:new => false}
			@m.set_new_if_not_defined params, true
			params[:new].should === false
		end
		
		# :moins
		it "doit répondre à :moins" do repond_a :moins end
		it ":moins doit retourner l'objet" do
		  @m.moins(1).class.should == Motif
		end
		it ":moins doit donner le motif avec les demi-tons en moins" do
			iv_set(SCORE, :key => nil)
		  @m.moins(1).to_s.should == "a fis e ees,4 a8"
			@m.moins(2).to_s.should == "aes f ees d,4 aes8"
			iv_set(SCORE, :key => 'G')
		  @m.moins(1).to_s.should == "a fis e dis,4 a8"
			@m.moins(2).to_s.should == "gis f dis d,4 gis8"
		end
		
		# :plus
		it "doit répondre à :plus" do repond_a :plus end
		it ":plus doit retourner l'objet" do
		  @m.plus(1).class.should == Motif
		end
		it ":plus doit donner le motif supérieur" do
			iv_set(SCORE, :key => nil)
		  @m.plus(1).to_s.should == "b aes fis f,4 b8"
			@m.plus(2).to_s.should == "c a g fis,4 c8"
			iv_set(SCORE, :key => 'Bb')
		  @m.plus(1).to_s.should == "b aes ges f,4 b8"
			@m.plus(2).to_s.should == "c a g ges,4 c8"
		end
		it ":plus avec le paramètre :new => false doit modifier l'objet" do
		  @motif = Motif::new "c d e"
			@motif.plus(1)
			iv_get(@motif, :motif).should == "c d e"
			@motif.plus(1, :new => false)
			iv_get(@motif, :motif).should == "des ees f"
		end
	
		# :legato
		it "doit répondre à :legato" do repond_a :legato end
		it ":legato doit renvoyer une instance du motif" do
		  @m.legato.class.should == Motif
		end
		it ":legato doit renvoyer une valeur modifiée" do
		  @mo = Motif::new "a b cis r4 a-^ |"
			res = @mo.legato
			res.to_s.should == "a( b cis r4 a-^) |"
		end
		it ":legato avec :new => true doit renvoyer un nouveau motif" do
		  @mo = Motif::new "a b d"
			@mo.legato
			iv_get(@mo, :motif).should == "a( b d)"
		  @mo = Motif::new "a b d"
			@mo.legato(:new => true)
			iv_get(@mo, :motif).should == "a b d"
		end

		# :surlegato
		it "doit répondre à :surlegato" do repond_a :surlegato end
		it ":surlegato doit renvoyer une instance du motif" do
		  @m.surlegato.class.should == Motif
		end
		it ":surlegato doit renvoyer une valeur modifiée" do
		  @mo = Motif::new "a b cis r4 a-^ |"
			res = @mo.surlegato
			res.to_s.should == "a\\( b cis r4 a-^\\) |"
		end
		
	end # / transformation du motif
end