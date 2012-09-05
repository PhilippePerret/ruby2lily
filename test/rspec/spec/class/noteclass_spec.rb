# 
# Tests de class NoteClass
# 
# @rappel: cette classe est héritée de toutes les classes qui 
# concernent les notes : Note, Motif, Chord...
# 
require 'spec_helper'
require 'noteclass'

describe NoteClass do
  describe "Class" do
		describe "Constantes" do
		  it "NoteClass::DUREES doit être défini" do
		    defined?(NoteClass::DUREES).should be_true
		  end
			it "NoteClass:DUREES doit définir les valeurs possibles" do
			  goods = ['1', '2', '4', '8', '16', '32', '64', '128', '256', '512']
				bads 	= ['1....', '3', 4000, 4, nil]
				goods.each do |duree| 
					NoteClass::DUREES.should have_key duree
					NoteClass::DUREES.should have_key "#{duree}."
					NoteClass::DUREES.should have_key "#{duree}.."
					NoteClass::DUREES.should have_key "#{duree}..."
				end
				bads.each do |bad_duree|
					NoteClass::DUREES.should_not have_key bad_duree
				end
			end
		end
    describe "::params_crochet_to_hash" do
			def methode params = nil
				NoteClass.params_crochet_to_hash(params)
			end
      it "doit exister" do
        NoteClass.should respond_to :params_crochet_to_hash
      end
			it "doit retourner un hash" do
			  methode.class.should == Hash
			end
			it "retourne un hash vide si paramètres nil" do
			  methode(nil).should == {}
			end
			it "doit retourner un hash définissant la durée" do
				params = ["1"]
				methode(params).should == {:duration => "1"}
				params = [{:duration => 2}]
				methode(params).should == {:duration => "2"}
				params = [{:duree => 4}]
				methode(params).should == {:duration => "4"}
			end
			it "doit retourner un hash définissant l'octave" do
			  params = [2]
				methode(params).should == {:octave => 2}
				params = [-1, 8]
				methode(params).should == {:octave => -1, :duration => "8"}
				params = [{:octave => 6}]
				methode(params).should == {:octave => 6}
			end
			it "ne doit pas retourner l'octave si [nil, <valeur>]" do
			  params = [nil, 4]
				methode(params).should == {:duration => "4"}
			end
			it "doit lever une erreur fatale si params n'est pas une liste" do
			  params = Chord::new("a c e")
				err = Liby::ERRORS[:bad_params_in_crochet]
				expect{methode(params)}.to raise_error(SystemExit, err)
			end
			it "doit lever une erreur fatale si mauvais argument dans params" do
				err = Liby::ERRORS[:bad_class_in_parameters_crochets]
			  params = [1, 2.3]
				expect{methode(params)}.to raise_error(SystemExit, err)
				params = [1, nil]
				expect{methode(params)}.to raise_error(SystemExit, err)
				params = [Note::new]
				expect{methode(params)}.to raise_error(SystemExit, err)
				params = [8, Note::new]
				expect{methode(params)}.to raise_error(SystemExit, err)
			end
			it "doit lever une erreur si trop de paramètres dans params" do
			  err = Liby::ERRORS[:too_much_parameters_to_crochets]
				params = [1,2,3]
				expect{methode(params)}.to raise_error(SystemExit, err)
			end
			it "doit lever une erreur si durée n'est pas une bonne valeur" do
				duree = 1000
			  err = detemp(Liby::ERRORS[:bad_value_duree], :bad => duree)
				expect{methode([nil, duree])}.to raise_error(SystemExit, err)
				duree = "3"
			  err = detemp(Liby::ERRORS[:bad_value_duree], :bad => duree)
				expect{methode([nil, duree])}.to raise_error(SystemExit, err)
				duree = "3."
			  err = detemp(Liby::ERRORS[:bad_value_duree], :bad => duree)
				expect{methode([nil, duree])}.to raise_error(SystemExit, err)
			end
    end
  end
end