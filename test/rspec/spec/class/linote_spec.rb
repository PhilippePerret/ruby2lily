# 
# Tests de la classe LINote
# 
require 'spec_helper'
require 'linote'

describe LINote do
	
	# -------------------------------------------------------------------
	# 	Classe
	# -------------------------------------------------------------------
  describe "La classe" do
    it "doit définir la constante NOTE_STR_TO_INT" do
      defined?(LINote::NOTE_STR_TO_INT).should be_true
    end
		it "NOTE_STR_TO_INT doit définir la correspondance" do
		  LINote::NOTE_STR_TO_INT["c"].should == 0
		end
		it "doit définir la constante NOTE_INT_TO_STR" do
		  defined?(LINote::NOTE_INT_TO_STR).should be_true
		end
		it "NOTE_INT_TO_STR doit définir la correspondance" do
		  LINote::NOTE_INT_TO_STR[4][:natural].should == "e"
		end
		it "doit définir la constante TONALITES" do
		  defined?(LINote::TONALITES).should be_true
		end
		it "TONALITES doit définir les tonalités" do
		  LINote::TONALITES['Bb'].should == {
				'fr' 			=> 'Si bémol majeur',
				'ton'			=> 'Bb',
				'bemols' 	=> 2,
				'dieses'	=> 0,
				"llp"			=>"bes"
		}
		end
  end # / classe
	describe "Méthodes de classe" do
		it "doit répondre à :note_str_in_context" do
		  LINote.should respond_to :note_str_in_context
		end
		it ":note_str_in_context doit renvoyer la bonne valeur" do
		  LINote::note_str_in_context(0).should == 'c'
			LINote::note_str_in_context(1, :tonalite => 'C').should == 'cis'
			LINote::note_str_in_context(1, :tonalite => 'F').should == 'des'
		end
	end # /méthodes de classe

	# -------------------------------------------------------------------
	# 	Instances
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @ln = LINote::new "c"
	  end
		it "doit répondre à :str_in_context" do
		  @ln.should respond_to :str_in_context
		end
		it ":str_in_context doit renvoyer la bonne valeur" do
			iv_set(@ln, :note_int => 3)
		  @ln.str_in_context(:tonalite => 'G').should 	== "dis"
		  @ln.str_in_context(:tonalite => 'Eb').should == "ees"
		end
		it "doit répondre à :moins" do
		  @ln.should respond_to :moins
		end
		it ":moins doit renvoyer la bonne valeur" do
			iv_set(@ln, :note_int => 0)
		  {
				1 => "b", 2 => "bes", 3 => "a", 4 => "aes",
				5 => "g", 6 => "fis", 7 => "f", 8 => "e",
				9 => "ees", 10 => "d", 11 => "cis", 12 => "c"
			}.each do |dt, ap|
				res = @ln.moins(dt)
				if res != ap
					debug "@ln.moins(#{dt}) aurait dû donner : #{ap}"
					res.should == ap
				end
			end
		end
		it "doit répondre à :plus" do
		  @ln.should respond_to :plus
		end
		it ":plus doit renvoyer la bonne valeur" do
		  {
				1 => "cis", 2 => "d", 3 => "ees", 4 => "e",
				5 => "f", 6 => "fis", 7 => "g", 8 => "aes",
				9 => "a", 10 => "bes", 11 => "b", 12 => "c"
			}.each do |dt, ap|
				res = @ln.plus(dt)
				if res != ap
					debug "@ln.plus(#{dt}) aurait dû donner : #{ap}"
					res.should == ap
				end
			end
		end
	end # / Instance
end