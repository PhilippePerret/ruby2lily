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
			describe "(généraliste) à" do
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
			describe "(hauteur) à" do
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
						@n.to_8(par).to_s.should == val
					end
				end
				it ":to_8 doit produire une erreur si l'argument est mauvais" do
				  expect{@n.to_8("bad")}.to raise_error
				end
			end # / méthode de hauteur
			
			# -------------------------------------------------------------------
			# 	Méthodes de durée
			# -------------------------------------------------------------------
			describe "(durée) à" do
				before(:all) do
				  @n = Note::new 'g'
				end
				it "doit répondre à duree=" do
				  @n.should respond_to :duree
				end
				it ":duree doit définir la durée" do
				  @n.duree 4
					iv_get(@n, :duration).should == 4
					@n.duree 3
					iv_get(@n, :duration).should == "2."
				end
				it ":duree doit retourner la durée" do
				  @n.duree 1
					@n.duree.should == 1
				end
				{
					'ronde' 		=> 1, 	'whole' 					=> 1, 
					'blanche' 	=> 2, 	'half' 						=> 2,
					'noire' 		=> 4, 	'quarter' 				=> 4,
					'croche' 		=> 8, 	'quaver' 					=> 8,
					'dbcroche' => 16, 	'semiquaver' 			=> 16, 
					'tpcroche'	=> 32,	'demisemiquaver' 	=> 32,
					'qdcroche' => 64,
					'cqcroche' => 128
				}.each do |len, duree|
					it ":#{len}" do
					  @n.should respond_to "#{len}"
					end
					it ":#{len} doit retourner une instance Note" do
					  @n.send(len).class.should == Note
					end
					it ":#{len} doit mettre la durée à #{duree}" do
						iv_set(@n, :duration => nil)
						iv_get(@n, :duration).should_not eq duree
					  @n.send(len)
						iv_get(@n, :duration).should eq duree
					end
				  it ":to_#{len}" do
			    	@n.should respond_to "to_#{len}"
				  end
					it ":to_#{len} doit mettre la durée à #{duree}" do
						iv_set(@n, :duration => nil)
						iv_get(@n, :duration).should_not eq duree
					  @n.send("to_#{len}")
						iv_get(@n, :duration).should eq duree
					end
					it ":as_#{len}" do
						@n.should respond_to "as_#{len}"
					end
					it ":as_#{len} doit renvoyer la bonne valeur" do
					  @n.send("as_#{len}").should == "g#{duree}"
					end
					it ":as_#{len} doit mettre la durée à #{duree}" do
						iv_set(@n, :duration => nil)
						iv_get(@n, :duration).should_not eq duree
					  @n.send("as_#{len}")
						iv_get(@n, :duration).should eq duree
					end
				end # / boucle sur toutes les durées
				it "doit répondre à :dotted et :pointee" do
				  @n.should respond_to :dotted
					@n.should respond_to :pointee
				end
				it ":pointee doit retourner une instance de Note" do
				  @n.pointee.class.should == Note
				end
				it ":pointee doit allonger la durée de la note" do
					[1, 2, 4, 8, 16].each do |n|
				  	iv_set(@n, :duration => n)
						@n.pointee
						iv_get(@n, :duration).should eq "#{n}."
					end
				end
			end
			describe "aux méthodes de durées" do
				
				
				# -------------------------------------------------------------------
				# 	Méthodes de durée renvoyant la note string
				# -------------------------------------------------------------------
				# -------------------------------------------------------------------
				# 	Méthode de durée ne renvoyant ni instance ni note string
				# -------------------------------------------------------------------				
				it ":to_dotted, :to_pointee" do
				  @n.should respond_to :to_dotted
					@n.should respond_to :to_pointee
				end
				it ":to_pointee doit définir @dotted" do
				  iv_set(@n, :duration => 4)
					@n.to_dotted
					iv_get(@n, :duration).should eq "4."
				  iv_set(@n, :duration => "2.")
					@n.to_dotted
					iv_get(@n, :duration).should eq "2."
				end
				
			end # /méthodes de durée

			# -------------------------------------------------------------------
			# 	Opérations sur les notes
			# -------------------------------------------------------------------
			describe "-Opérations-" do
			  it "doit répondre à :+" do
			    @n.should respond_to :+
			  end
				it ":+ doit permettre d'addition des notes" do
				  res = (ut + re)
					res.class.should == Motif
					ut.to_s.should eq "c'''"
					re.to_s.should eq "d'''"
					res.to_s.should eq "\\relative c''' { c d }"
				end
				it ":+ avec deux notes d'octave différentes doit produire deux motifs" do
				  coct4 = Note::new "c", :octave => 4
					aoct1 = Note::new "a", :octave => 1
					res = (coct4 + aoct1)
					puts "res: #{res.inspect}"
				end
			end
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