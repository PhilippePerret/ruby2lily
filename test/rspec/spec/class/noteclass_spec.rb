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
		describe "Méthodes durées" do
		  it "doit répondre à :duree_valide?" do
		    NoteClass.should respond_to :duree_valide?
		  end
		  [
				["1", "1"], ["1..", "1.."], ["1..~", "1..~"],
				["~", "~"], ["256", "256"], ["256..", "256.."],
				[1, "1"], [2, "2"], [3, false],
				[".1", false], ["3", false], ["a", false]
			].each do |d|
				duree, valide = d
				it "La durée '#{duree}' doit être considérée #{valide ? 'valide' : 'invalide'}" do
				  NoteClass::duree_valide?(duree).should === valide
				end
			end
			it ":duree_valide? doit lever une erreur fatale si fatal = true" do
			  expect{NoteClass::duree_valide?(3)}.not_to raise_error
				err = detemp(Liby::ERRORS[:bad_value_duree], :bad => 3)
				expect{NoteClass::duree_valide?(3,true)
					}.to raise_error(SystemExit, err)
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
	describe "Instance" do
		before(:each) do
		  @nc = NoteClass::new
		end
	  it "doit répondre à :set_params" do
	    @nc.should respond_to :set_params
	  end
		[
			"string", [1,2,3], Motif::new("a( b c)"), 5
		].each do |bad_param|
			it ":set_params doit lever une erreur en cas d'argument #{bad_param.class}" do
				err = detemp(Liby::ERRORS[:bad_type_for_args], 
					:method => "NoteClass#set_params", :good => "Hash", 
					:bad => bad_param.class.to_s)
			  expect{@nc.set_params(bad_param)}.to raise_error(SystemExit, err)
			end
		end
		it ":set_params doit toujours transformer 'duree' en 'duration' et en string" do
		  mot = Motif::new "a b c"
			iv_get(mot, :duration).should be_nil
			mot.set_params :duree => 8
			iv_get(mot, :duration).should == "8"
			mot = Motif::new "a b c", :duree => 4
			iv_get(mot, :duration).should == "4"
			mot = Motif::new :notes => "a b c", :duree => 16
			iv_get(mot, :duration).should == "16"
		end
		[
			1, 2, 4, 8, "1.", "1..", "1..~", "4~", "~", 256
		].each do |duree|
			it ":set_params ne doit pas lever d'erreur pour une durée de #{duree}" do
				mot = Motif::new "a b c" 
			  expect{mot.set_params(:duree => duree)}.not_to raise_error
		  end
		end
		[
			3, "4^", ".8", 1254
		].each do |duree|
			it ":set_params doit lever une erreur si la durée est mauvaise" do
				err = detemp(Liby::ERRORS[:bad_value_duree], :bad => duree.to_s)
				mot = Motif::new "a b c" 
				expect{mot.set_params(:duree => duree)}.to \
					raise_error(SystemExit, err)
			end
		end
		it ":set_params doit transformer l'octave en nombre" do
		  mot = Motif::new "a b c"
			mot.set_params :octave => "5"
			iv_get(mot, :octave).should === 5
		end
		it ":set_params doit lever une erreur si l'octave est trop petit ou trop grand" do
		  expect{Motif.new("a", :octave => -2)}.not_to raise_error
			oct = -3
			err = detemp(Liby::ERRORS[:bad_value_octave], 
				:bad => oct, :class => "LINote")
			expect{Motif.new("a", :octave => oct)}.to \
				raise_error(SystemExit, err)
			oct = 11
			err = detemp(Liby::ERRORS[:bad_value_octave], 
				:bad => oct, :class => "LINote")
			expect{Motif.new("a", :octave => oct)}.to \
				raise_error(SystemExit, err)
		end
		it ":set_params doit faire son travail correctement" do
			# :set_params fonctionne ainsi : si une méthode `set_<property>`
			# existe pour l'objet, elle est utilisée pour définir la valeur de
			# la propriété. Dans le cas contraire, on utilise tout simplement
			# instance_variable_set
		  # Pour le tester, il faut utiliser une classe de note qui utilise
			# ce principe (par exemple la classe Motif, qui traduit la clef
			# définie en la transformant en clé LilyPond)
			mot = Motif::new "a b c"
			mot.set_params :clef => "g"
			iv_get(mot, :clef).should == "treble"
		end
	end
end