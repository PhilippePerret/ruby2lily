# 
# Tests de la class Checker
# 
require 'spec_helper'
require 'checkif'

describe Checkif do
	def repond_a cle
		Checkif.should respond_to cle
	end
	def has_error cle
		Checkif::ERRORS.should have_key cle
	end
	describe "Constantes erreurs" do
	  it "ERRORS doit être défini" do
	    defined?(Checkif::ERRORS).should be_true
	  end
		# Liste des erreurs qui doivent être définies
		it "ERRORS doit définir :undefined" do has_error :undefined end
		it "ERRORS doit définir :not_a_string" do has_error :not_a_string end
		it "ERRORS doit définir :not_a_array" do has_error :not_a_array end
		it "ERRORS doit définir :not_a_hash" do has_error :not_a_hash end
		it "ERRORS doit définir :not_a_key_of" do has_error :not_a_key_of end
	end
  describe "Méthodes statiques générales" do
		
		# ::raise_error
		it ":raise_error doit exister" do repond_a :raise_error end
		it ":raise_error doit lever une erreur" do
		  expect{Checkif.raise_error("l'erreur")}.to raise_error(Exception, "l'erreur")
		end
		
		# ::raise_fatal
		it ":raise_fatal doit exister" do repond_a :raise_fatal end
		it ":raise_fatal doit lever une erreur fatale" do
		  expect{Checkif.raise_fatal("Erreur Fatale")}.to \
				raise_error(SystemExit, "Erreur Fatale")
		end
		
		# ::formate_error
		it ":formate_error doit exister" do repond_a :formate_error end
		it ":formate_error doit renvoyer la bonne valeur" do
		  res = Checkif::formate_error(:undefined, :var => "mavar")
			res.should === "La valeur `mavar' doit être définie !"
		end
		it ":formate_error doit utiliser le message fourni s'il existe" do
		  res = Checkif::formate_error("alt message", {})
			res.should == "alt message"
		end
		
		# ::generate_error
		it ":generate_error doit exister" do repond_a :generate_error end
		it ":generate_error doit lever une erreur fatale si demandée" do
		  expect{Checkif::generate_error(nil, :undefined, :fatal => true)
			}.to raise_error(SystemExit)
		end
		it ":generate_error doit lever une erreur normale sinon" do
		  expect{
				Checkif::generate_error(nil, :undefined)
			}.not_to raise_error(SystemExit)
		end
		it ":generate_error doit lever une erreur personnalisée si définie" do
			altmess = "Un message d'erreur personnalisé"
			errdef	= Checkif::ERRORS[:undefined]
		  expect{Checkif::generate_error(nil, :undefined, :message => nil)
			}.to raise_error(Exception, errdef)
		  expect{Checkif::generate_error(nil, :undefined, :message => altmess)
			}.to raise_error(Exception, altmess)
		end
	end
	describe "Méthodes de test" do
		# ::defined
		it ":defined doit exister" do repond_a :defined end
		it ":defined doit renvoyer la bonne valeur" do
			err = detemp(Checkif::ERRORS[:undefined], :var => "@defini")
		  expect{Checkif::defined('ca', :var => "@defini")
			}.to raise_error(Exception, err)
			Checkif::defined('Checkif').should be_true
		end
		
		# ::string
		it ":string doit exister" do repond_a :string end
		it ":string doit renvoyer true si c'est une chaine" do
		  Checkif::string("ça").should === true
		end
		it ":string doit lever une erreur si pas chaine" do
			err = detemp(Checkif::ERRORS[:not_a_string], :var => "mavar")
		  expect{Checkif::string([], :var => "mavar")}.to raise_error(
				Exception, err
			)
		end
		it ":string doit lever une erreur fatale si nécessaire" do
			err = detemp(Checkif::ERRORS[:not_a_string], :var => "mavar")
		  expect{Checkif::string([], :var => "mavar", :fatal => true)
			}.to raise_error( SystemExit, err )
		end
		
		# ::array
		it ":array doit exister" do repond_a :array end
		it ":array doit renvoyer true si c'est un array" do
		  Checkif::array([]).should === true
		end
		it ":array doit lever une erreur si pas array" do
			err = detemp(Checkif::ERRORS[:not_a_array], :var => "@variable")
		  expect{Checkif::array("ca", :var => "@variable")
			}.to raise_error(Exception, err)
		end
		it ":array doit lever une erreur fatale si pas array et fatal" do
			err = detemp(Checkif::ERRORS[:not_a_array], :var => "@variable")
		  expect{Checkif::array("ca", :var => "@variable", :fatal => true)
			}.to raise_error(SystemExit, err)
		end
		# ::array
		it ":hash doit exister" do repond_a :hash end
		it ":hash doit renvoyer true si c'est un hash" do
		  Checkif::hash({}).should === true
		end
		it ":hash doit lever une erreur si pas hash" do
			err = detemp(Checkif::ERRORS[:not_a_hash], :var => "@variable")
		  expect{Checkif::hash("ca", :var => "@variable")
			}.to raise_error(Exception, err)
		end
		
		# :is_key_of
		it ":is_key_of doit exister" do repond_a :is_key_of end
		it ":is_key_of doit renvoyer true en cas de succès" do
		  Checkif::is_key_of(:undefined, :hash => Checkif::ERRORS).should === true
		end
		it ":is_key_of doit lever une erreur en cas d'échec" do
		  err = detemp(Checkif::ERRORS[:not_a_key_of], :var => "@variable")
		  expect{Checkif::is_key_of("ca", :hash => {}, :var => "@variable")
			}.to raise_error(Exception, err)
		end
  end # / méthodes de tests
end