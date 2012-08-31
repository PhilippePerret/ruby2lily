# 
# Tests de la class Staff (Portée)
# 
require 'spec_helper'
require 'staff'

describe Staff do
  describe "La classe" do
    it "doit répondre à :new" do
      Staff.should respond_to :new
    end
		it ":new doit créer une nouvelle instance" do
		  @s = Staff::new
			@s.class.should == Staff
		end
  end # / la classe
	describe "L'instance" do
		before(:each) do
		  @s = Staff::new
		end
	  it "doit répondre à :tempo" do
	    @s.should respond_to :tempo
	  end
		it "doit répondre à :tempo=" do
		  @s.should respond_to :tempo=
		end
		it ":tempo= doit définir le tempo" do
		  @s.tempo = 64
			iv_get(@s, :tempo).should == 64
			iv_get(@s, :base_tempo).should be_nil
			@s.tempo 			= 120
			@s.base_tempo = "4."
			iv_get(@s, :tempo).should == 120
			iv_get(@s, :base_tempo).should == "4."
		end
		it ":tempo= doit lever une erreur en cas de mauvaise valeur" do
			expect{@s.tempo = -2}.to raise_error Staff::ERRORS[:bad_tempo_value]
		end
		it "doit répondre à :clef" do
		  @s.should respond_to :clef
		end
		it "doit répondre à :clef=" do
		  @s.should respond_to :clef=
		end
		it "clef= doit lever une erreur en cas de mauvaise valeur" do
		  expect{@s.clef = "bad"}.to raise_error
		end
		
	end # / l'instance
	
	describe "L'affichage de la portée" do
	  before(:each) do
	    @s = Staff::new
	  end
		it "doit répondre à :to_llp, :to_lilipond" do
		  @s.should respond_to :to_llp
			@s.should respond_to :to_lilipond
		end
		it ":to_llp doit retourner la bonne valeur" do
			code_llp = "{\n}"
		  @s.to_llp.should == code_llp
			@s.tempo = 120
			@s.to_llp.should == "{\n\t\\tempo 4 = 120\n}"
			@s.tempo = "Moderato"
			@s.to_llp.should == "{\n\t\\tempo \"Moderato\" 4 = 120\n}"
			@s.clef = "treble"
			@s.to_llp.should == "{\n\t\\clef \"treble\"\n\t\\tempo \"Moderato\" 4 = 120\n}"
		end
		
		# :mark_tempo
		it "doit répondre à mark_tempo" do
		  @s.should respond_to :mark_tempo
		end
		it ":mark_tempo doit retourner la bonne valeur" do
		  @s.mark_tempo.should be_nil
			@s.tempo = 60
			@s.mark_tempo.should == "\t\\tempo 4 = 60"
			@s.base_tempo = 1
			@s.mark_tempo.should == "\t\\tempo 1 = 60"
			@s.tempo = "Largo"
			@s.mark_tempo.should == "\t\\tempo \"Largo\" 1 = 60"
		end
		
		# :mark_clef
		it "doit répondre à :mark_clef" do
		  @s.should respond_to :mark_clef
		end
		it ":mark_clef doit retourner la bonne valeur" do
		  @s.mark_clef.should be_nil
			@s.clef = "treble"
			@s.mark_clef.should == "\t\\clef \"treble\""
			@s.clef = "fa"
			@s.mark_clef.should == "\t\\clef \"bass\""
		end
	end
end
