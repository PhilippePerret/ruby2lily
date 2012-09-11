# 
# Test de la classe Note
# 
require 'spec_helper'
require 'note'

describe Note do
	# -------------------------------------------------------------------
	# 	La classe
	# -------------------------------------------------------------------
	describe "class" do
		describe "Constantes" do
		  it "d oit définir NOTE_TO_VAL_ABS" do
		    defined?(Note::NOTE_TO_VAL_ABS).should be_true
		  end
			it "NOTE_TO_VAL_ABS d oit définir les bonnes valeurs" do
			  Note::NOTE_TO_VAL_ABS['c'].should == 1
				Note::NOTE_TO_VAL_ABS['g'].should == 8
				Note::NOTE_TO_VAL_ABS['b'].should == 12
			end
		end
	  describe "doit répondre" do
			describe "à la méthode généraliste" do
			  it ":create_note" do
			    Note.should respond_to :create_note
			  end
			end
	    describe "à la méthode de hauteur" do
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
		describe "- méthodes -" do
		  it ":create_note doit créer une note" do
		    res = Note::create_note("c")
				res.class.should == Note
				res.it.should == "c"
				res.octave.should == 3
		  end
		
			# :split_note_et_octave
			it ":split_note_et_octave doit exister" do
			  Note.should respond_to :split_note_et_octave
			end
			it ":split_note_et_octave doit retourner la bonne valeur" do
			  Note::split_note_et_octave('c').should == ['c', nil]
				Note::split_note_et_octave('d,').should == ['d', -1]
				Note::split_note_et_octave("e''''").should == ['e', 4]
				Note::split_note_et_octave('f,,,').should == ['f', -3]
			end
		
			# :valeur_absolue
			it ":valeur_absolue d oit exister" do
			  Note.should respond_to :valeur_absolue
			end
		  [
				["c", 0, 1], ["cis", 0, 2],
				["d", 0, 3], ["dis", 0, 4], 
				["e", 0, 5], 
				["f", 0, 6], ["eis", 0, 6],
				["g", 0, 8], ["fisis", 0, 8], ["aeses", 0, 8],
				["a", 0, 10], 
				["b", 0, 12], ["ces", 1, 12],
				["c", 1, 13],
				["c", 2, 25],
				["c", 3, 37],
				
				["c", -1, -11],
				["c", -2, -23],
				["bes", -3, -25],
				["f",   -3, -30]
			].each do |note, octave, valeur|
				it "La note #{note} à l'octave #{octave} vaut #{valeur}" do
					Note::valeur_absolue(note, octave).should == valeur
				end
			end
			
			# :dieses_et_bemols_in
			it ":dieses_et_bemols_in doit exister" do
			  Note.should respond_to :dieses_et_bemols_in
			end
			it ":dieses_et_bemols_in d oit retourner la bonne valeur" do
			  Note::dieses_et_bemols_in("ais").should == [1, 0]
			  Note::dieses_et_bemols_in("aisis").should == [2, 0]
			  Note::dieses_et_bemols_in("aes").should == [0, 1]
			  Note::dieses_et_bemols_in("aises").should == [1, 1]
			  Note::dieses_et_bemols_in("aeses").should == [0, 2]
			  Note::dieses_et_bemols_in("aesis").should == [1, 1]
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
				it ":initialize doit définir @it si la note est fourni" do
				  @n = Note::new "c"
					@n.it.should == "c"
				end
				it ":initialize doit traiter une note fournie avec octave" do
				  @n = Note::new "c,"
					@n.it.should == "c"
					@n.octave.should == 2
				end
				
				# :set
				it ":set" do
				  @n.should respond_to :set
				end
				it ":set doit traiter une note anglaise simple" do
				  @n.set 'd'
					@n.it.should == "d"
					iv_get(@n, :itit).should == "ré"
					@n.octave.should == 3
				end
				it ":set doit traiter une note italienne simple" do
				  @n.set 'si'
					@n.it.should == "b"
					iv_get(@n, :itit).should == "si"
					@n.octave.should == 3
				end
				it ":set doit traiter une anglaise avec octave" do
				  @n.set "f'"
					@n.it.should == "f"
					iv_get(@n, :itit).should == "fa"
					@n.octave.should == 4
				end
				it ":set doit traiter une italienne avec octave" do
				  @n.set "sol,,"
					@n.it.should == "g"
					iv_get(@n, :itit).should == "sol"
					@n.octave.should == 1
				end
				it ":set doit traiter un silence" do
				  @n.set "r"
					@n.it.should be_nil
					iv_get(@n, :rest).should be_true
					iv_get(@n, :itit).should be_nil
				end

				# :to_s
				it ":to_s" do
				  @n.should respond_to :to_s
				end
				[
					["c", nil, nil, "c"],
					["c", 2, nil, "\\relative c'' { c }"],
					["ceses", 4, "4", "\\relative c'''' { ceses4 }"],
					["fisis", 3, "4.", "fisis4."]
				].each do |d|
					note, octave, duree, expected = d
					it "Note « #{note}#{duree} »-oct:#{octave}:to_s should: #{expected}" do
					  no = Note::new note, :octave => octave, :duration => duree
						no.to_s.should == expected
					end
				end
				
				# :get
				it ":get" do
				  @n.should respond_to :get
				end
				it ":get doit renvoyer la bonne valeur" do
				  iv_set(@n, :it => nil)
					@n.get.should be_nil
					@n.set 'c'
					@n.get.should == 'c'
				end
				
				it ":as_motif" do
				  @n.should respond_to :as_motif
				end
				it ":as_motif doit renvoyer la note comme motif" do
				  n = Note::new "c,,,"
					mo = n.as_motif
					mo.class.should == Motif
					mo.notes.should == "c"
					mo.octave.should == 0
				end
				it ":to_silence" do
				  @n.should respond_to :to_silence
					@n.should respond_to :to_rest
				end
				it ":to_silence doit définir un silence" do
				  iv_set(@n, :rest => false)
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
					iv_get(@n, :duration).should == "4"
					@n.duree 3
					iv_get(@n, :duration).should == "2."
				end
				it ":duree doit retourner la durée" do
				  @n.duree 1
					@n.duree.should == "1"
				end
				{
					'ronde' 		=> 1, 	'whole' 					=> 1, 
					'blanche' 	=> 2, 	'half' 						=> 2,
					'noire' 		=> 4, 	'quarter' 				=> 4,
					'croche' 		=> 8, 	'quaver' 					=> 8,
					'dbcroche' 	=> 16, 	'semiquaver' 			=> 16, 
					'tpcroche'	=> 32,	'demisemiquaver' 	=> 32,
					'qdcroche' 	=> 64,
					'cqcroche' 	=> 128
				}.each do |len, duree|
					it ":#{len}" do
					  @n.should respond_to "#{len}"
					end
					it ":#{len} doit retourner une instance Note" do
					  @n.send(len).class.should == Note
					end
					it ":#{len} doit mettre la durée à #{duree}" do
						iv_set(@n, :duration => nil)
						iv_get(@n, :duration).should_not eq duree.to_s
					  @n.send(len)
						iv_get(@n, :duration).should eq duree.to_s
					end
				  it ":to_#{len}" do
			    	@n.should respond_to "to_#{len}"
				  end
					it ":to_#{len} doit mettre la durée à #{duree}" do
						iv_set(@n, :duration => nil)
						iv_get(@n, :duration).should_not eq duree.to_s
					  @n.send("to_#{len}")
						iv_get(@n, :duration).should eq duree.to_s
					end
					it ":as_#{len}" do
						@n.should respond_to "as_#{len}"
					end
					it ":as_#{len} doit renvoyer la bonne valeur" do
					  res = @n.send("as_#{len}")
						res.should == "g#{duree}"
					end
					it ":as_#{len} doit mettre la durée à #{duree}" do
						iv_set(@n, :duration => nil)
						iv_get(@n, :duration).should_not eq duree.to_s
					  @n.send("as_#{len}")
						iv_get(@n, :duration).should eq duree.to_s
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
				it ":to_pointee doit modifier la durée" do
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
				it ":+ doit produire un Motif" do
					(ut + re).class.should == Motif
					# Les autres tests sont fait dans operation/addition_spec.rb
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
				  iv_set(@n, :duration => "2." )
					@n.mark_duration.should == "2."
				end
			end
	  end
	end
end