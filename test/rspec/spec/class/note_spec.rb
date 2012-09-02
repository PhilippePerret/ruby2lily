# 
# Test de la classe Note
# 
require 'spec_helper'
require 'note'

describe Note do
	# -------------------------------------------------------------------
	# 	La classe
	# -------------------------------------------------------------------
	describe "La classe" do
	  describe "doit répondre" do
	    describe "aux méthodes de hauteur" do
	      it ":current_octave, :octave_courant" do
	        Note.should respond_to :current_octave
					Note.should respond_to :octave_courant
	      end
				it ":current_octave=, :octave_courant=" do
				  Note.should respond_to :current_octave=
					Note.should respond_to :octave_courant=
				end
				it ":octave_courant= doit permettre de définir l'octave courant" do
				  cv_set(Note, :current_octave => nil)
					Note::octave_courant = 2
					cv_get(Note, :current_octave).should == 2
					Note::octave_courant = 4
					cv_get(Note, :current_octave).should == 4
				end
				it ":octave_courant= doit lever une erreur si mauvaise valeur" do
				  expect{ Note::octave_courant("bad") }.to raise_error
				 	expect{ Note::octave_courant(-9) 		}.to raise_error
				 	expect{ Note::octave_courant(9) 		}.to raise_error
				end
				it ":current_octave doit renvoyer la bonne valeur" do
				  cv_set(Note, :current_octave => nil)
				  Note::current_octave.should be_nil
					Note::octave_courant = 4
				  Note::octave_courant.should == 4
				end
	    end
	  end
	end
	# -------------------------------------------------------------------
	# 	L'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:all) do
	    @n = Note.new
	  end
	  describe "doit répondre" do
			# -------------------------------------------------------------------
			# 	Méthodes généralistes
			# -------------------------------------------------------------------
			describe "aux méthodes généralistes" do
				it ":set" do
				  @n.should respond_to :set
				end
				it ":set qui doit donner la bonne valeur" do
				  iv_set(@n, :it => 'c')
					@n.set 'd'
					iv_get(@n, :it).should == 'd'
					@n.set 'do'
					iv_get(@n, :it).should == 'c'
				end
				it ":get" do
				  @n.should respond_to :get
				end
				it ":get doit renvoyer la bonne valeur" do
				  iv_set(@n, :it => nil)
					@n.get.should be_nil
					@n.set 'c'
					@n.get.should == 'c'
				end
				it ":to_silence" do
				  @n.should respond_to :to_silence
					@n.should respond_to :to_rest
				end
				it ":to_silence doit définir un silence" do
				  iv_set(@n, :silence => nil)
					@n.should_not be_silence
					@n.to_silence
					@n.should be_rest
				end
			end
			# -------------------------------------------------------------------
			# 	Méthodes de hauteur
			# -------------------------------------------------------------------
			describe "aux méthodes de hauteur" do
				it ":octave=" do
				  @n.should respond_to :octave=
				end
				it ":octave= avec une bonne valeur doit définir l'octave" do
				  iv_set(@n, :octave => nil)
					@n.octave= 3
					iv_get(@n, :octave).should == 3
				end
				it ":octave= avec un mauvais argument doit renvoyer une erreur" do
				  iv_set(@n, :octave => nil)
					expect{ @n.octave= "bad"	}.to raise_error
					expect{ @n.octave= -12		}.to raise_error
					expect{ @n.octave= 12 		}.to raise_error
				end
				it ":octave" do
				  @n.should respond_to :octave
				end
				it ":octave doit renvoyer la bonne valeur" do
				  iv_set(@n, :octave => nil)
					@n.octave.should be_nil
				  iv_set(@n, :octave => 4)
					@n.octave.should == 4
				end
		    it ":to_8" do
					@n.should respond_to :to_8
		    end
				it "qui doit renvoyer la bonne valeur" do
					iv_set(@n, :it => 'c')
					[
						[nil, "c'"], [-1, "c,"], [false, "c,"],
						[2, "c''"], [-2, "c,,"]
					].each do |paire|
						par, val = paire
						@n.to_8(par).should == val
					end
				end
				it ":to_8 doit produire une erreur si l'argument est mauvais" do
				  expect{@n.to_8("bad")}.to raise_error
				end
			end # / méthode de hauteur
			
			# -------------------------------------------------------------------
			# 	Méthodes de durée
			# -------------------------------------------------------------------
			describe "aux méthodes de durées" do
			  it ":to_whole, to_ronde" do
			    @n.should respond_to :to_whole
					@n.should respond_to :to_ronde
			  end
				it ":to_ronde doit définir la bonne durée de la note" do
				  iv_set(@n, :duration => nil)
					@n.to_ronde
					iv_get(@n, :duration).should == 1
				end
				it ":to_half, :to_blanche" do
				  @n.should respond_to :to_half
					@n.should respond_to :to_blanche
				end
				it ":to_blanche doit définir la bonne durée" do
					iv_set(@n, :duration => nil)
					@n.to_blanche
					iv_get(@n, :duration).should == 2
				end
				it ":to_quarter, :to_noire" do
				  @n.should respond_to :to_quarter
					@n.should respond_to :to_noire
				end
				it ":to_noire doit définir la bonne durée" do
				  iv_set(@n, :duration => nil)
					@n.to_noire
					iv_get(@n, :duration).should == 4
				end
				it ":to_quaver, :to_croche" do
				  @n.should respond_to :to_croche
					@n.should respond_to :to_quaver
				end
				it ":to_croche doit définir la bonne durée" do
				  iv_set(@n, :duration => nil)
					@n.to_croche
					iv_get(@n, :duration).should == 8
				end
				it ":to_croche avec un argument doit définir la bonne durée" do
					iv_set(@n, :duration => nil)
					@n.to_croche(2).should == @n.to_dblcroche
					@n.to_croche(3).should == @n.to_tplcroche
				end
				it ":to_semiquaver :to_dblcroche" do
				  @n.should respond_to :to_semiquaver
					@n.should respond_to :to_dblcroche
				end
				it ":to_dblcroche doit définir la bonne durée" do
				  iv_set(@n, :duration => nil)
					@n.to_dblcroche
					iv_get(@n, :duration).should == 16
				end
				it ":to_tplcroche, :to_demisemiquaver" do
				  @n.should respond_to :to_tplcroche
					@n.should respond_to :to_demisemiquaver
				end
				it ":to_tplcroche doit définir la bonne durée" do
				  iv_set(@n, :duration => nil)
					@n.to_tplcroche
					iv_get(@n, :duration).should == 32
				end
				
				it ":to_dotted, :to_pointee" do
				  @n.should respond_to :to_dotted
					@n.should respond_to :to_pointee
				end
				it ":to_pointee doit définir @dotted" do
				  iv_set(@n, :dotted => nil)
					@n.to_dotted
					iv_get(@n, :dotted).should be_true
					@n.to_dotted false
					iv_get(@n, :dotted).should be_false
				end
			end # /méthodes de durée

			# -------------------------------------------------------------------
			# 	Méthodes d'affichage
			# -------------------------------------------------------------------
			describe "aux méhodes d'affichage" do
				it ":mark_duration" do
				  @n.should respond_to :mark_duration
				end
				it ":mark_duration doit renvoyer la bonne valeur" do
				  iv_set(@n, :duration => 4, :dotted => false )
					@n.mark_duration.should == "4"
				  iv_set(@n, :duration => 2, :dotted => true )
					@n.mark_duration.should == "2."
				end
			end
	  end
	end
end