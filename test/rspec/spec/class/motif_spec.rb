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
			iv_get(@m, :notes).should be_nil
    end
		it "avec argument string doit définir un motif" do
		  @m = Motif::new "a b c"
			@m.notes.should == "a b c"
			@m.octave.should == 4
			@m.duration.should be_nil
		end
		it "avec deux arguments, les notes et les paramètres" do
		  mo = Motif::new "d b a", :octave => 1, :duration => "4.", :slured => true
			mo.class.should == Motif
			mo.notes.should == "d b a"
			mo.should be_slured
			mo.octave.should == 1
			mo.duration.should == "4."
			mo.to_s.should == "\\relative c,, { d4.( b a) }"
		end
		it "avec argument hash pour définir le motif et l'octave" do
		  @m = Motif::new :notes => "d b a", :octave => 4
			iv_get(@m, :notes).should 	== "d b a"
			iv_get(@m, :octave).should 	== 4
		end
		it "avec seulement des silences, doit être possible" do
		  expect{Motif::new("r r r r")}.not_to raise_error
		end
		it "quand première note avec durée, on la retire et on la conserve" do
		  suite = "r1 r r r"
			mo = Motif::new suite
			mo.notes.should == "r r r r"
			mo.duration.should == "1"
			mo.to_s.should == "\\relative c' { r1 r r r }"
		end
		it "doit pouvoir accepter des accords" do
		  mo = Motif.new "<e g c>4 <e g c> <e g c>"
			mo.to_llp.should == "<e g c>4 <e g c> <e g c>"
			mo.to_s.should == "\\relative c' { <e g c>4 <e g c> <e g c> }"
		end
		it "<motif> doit répondre à :rationnalize_durees" do
		  mo = Motif::new "c d e"
			mo.should respond_to :rationnalize_durees
		end
		it ":rationnalize_durees doit rationnaliser les durées" do
			
		  mo = Motif::new "c1 d1"
			mo.notes.should == "c d" # @fixme: DEVRAIT ÊTRE COMME ICI
			mo.duration.should == "1"
			
			mo = Motif::new( :notes => "c4. d4. e4. f1" )
			mo.notes.should == "c d e f1"
			mo.duration.should == "4."
			
			mo = Motif::new "c d4 f4"
			mo.notes.should == "c d4 f4"
			mo.duration.should be_nil
			
		end
		it "on doit supprimer les marques de durée similaires" do
		  
		end
		it "doit définir la méthode :set_properties pour l'instanciation" do
			mot = Motif::new "a b c"
		  mot.should respond_to :set_properties
		end
		it ":set_properties doit faire son travail" do
		  # note: cette méthode utilise NoteClass#set_params, qui est testée
			# en profondeur dans class/noteclass_spec.rb
			mot = Motif::new "a b c"
			iv_get(mot, :octave).should == 4
			mot.set_properties :octave => "5"
			iv_get(mot, :octave).should === 5
			iv_get(mot, :slured).should be_false
			mot.set_properties :slured => true
			iv_get(mot, :slured).should === true
			mot.set_properties :slured => false
			iv_get(mot, :legato).should be_false
			mot.set_properties :legato => true
			iv_get(mot, :legato).should === true
		end
		
  end
	describe "<motif>" do
		before(:each) do
		  @m = Motif::new
		end
		after(:each) do
		  $DEBUG_ON = false
		end
		
		# :to_hash
		it "doit répondre à :to_hash" do
		  @m.should respond_to :to_hash
		end
		it ":to_hash doit retourner la bonne valeur" do
		  mo = Motif::new
			mo.to_hash.should == {
				:notes => nil,
				:octave => nil, 
				:slured => false, 
				:legato => false,
				:triolet => nil,
				:duration	=> nil,
				:clef			=> nil
			}
			data = { :notes => "a b c", :slured => true, :triolet => true,
							 :duration => "4.", :clef => "sol" }
			mo = Motif::new data.dup
			mo.to_hash.should == data.merge(
				:octave => 4, :legato => false, :clef => "treble", 
				:triolet => "2/3"
			)
		end
		# :count / :nombre_notes
		it "doit répondre à :count et :nombre_notes" do
		  @m.should respond_to :count
			@m.should respond_to :nombre_notes
		end
		it ":count doit renvoyer le bon nombre de notes" do
		  mo = Motif::new "a b"
			mo.count.should == 2
			mo = Motif::new "a( b c d)"
			mo.count.should == 4
			# Cas spécial de l'accord
			mo = Motif::new "<a c e>"
			mo.count.should == 1
			mo.count(real=true).should == 3
			mo = Motif::new "r <c e g> r"
			mo.count.should == 3
			mo.count(real=true).should == 5
		end
		# :set_with_string
		it "doit répondre à :set_with_string" do
		  @m.should respond_to :set_with_string
		end
		it ":set_with_string doit définir correctement le motif" do
			mo = Motif::new
		  mo.set_with_string "c"
			mo.notes.should == "c"
			mo.duration.should == nil
			mo.octave.should == 4

			# Une suite "complète" de traitement de la note
			mo = Motif::new "do#4."
			mo.notes.should == "cis"
			mo.duration.should == "4."
			mo.octave.should == 4
			
			mo = Motif::new "cbb( e4 g#) <c e g>8"
			mo.notes.should == "ceses( e4 gis) <c e g>8"
			mo.duration.should be_nil
			mo.octave.should == 4
		end
		
		# :set
		it "doit répondre à :set" do
		  @m.should respond_to :set
		end
		it ":set doit permettre de définir les valeurs" do
		  motif = Motif::new "a b c"
			motif.get(:slured).should be_false
			motif.set :slured => true
			motif.get(:slured).should be_true
			motif.set :notes => "d e f"
			motif.notes.should == "d e f"
		end
		
		# :get
		it "doit répondre à :get" do
		  motif = Motif::new "a b c", :slured => true
			motif.get( :notes ).should == "a b c"
			motif.get(:slured).should be_true
			motif.get(:legato).should be_false
		end
		
		# :to_s
	  it "doit répondre à :to_s" do repond_a :to_s end
		it ":to_s doit renvoyer nil si le motif n'est pas défini" do
			iv_set(@m, :notes => nil)
		  @m.to_s.should be_nil
		end
		it ":to_s doit renvoyer le motif s'il est défini" do
		  iv_set(@m, :notes => "a b c")
			@m.to_s.should == "\\relative c' { a b c }"
		end
		it ":to_s doit renvoyer le motif avec une durée si elle est définie" do
		  iv_set(@m, :notes => "c d e")
			@m.to_s("1").should == "\\relative c' { c1 d e }"
		end
		it ":to_s doit modifier l'octave si l'argument est un nombre" do
		  iv_set(@m, :notes => "c d e")
			@m.to_s(2).should == "\\relative c, { c d e }"
		end
		it ":to_s doit renvoyer le motif à la bonne hauteur d'octave" do
		  iv_set(@m, :notes => "c d e")
			@m.to_s(:octave => -2).should == "\\relative c,,,,, { c d e }"
		end
		it ":to_s doit renvoyer la bonne valeur avec deux motifs de même octave" do
		  @m1 = Motif::new :notes => "a a a", :octave => 3
		  @m2 = Motif::new :notes => "b b b", :octave => 3
			(@m1 + @m2).to_s.should == "\\relative c { a a a b b b }"
		end
		it ":to_s doit renvoyer la bonne valeur avec deux motifs d'octave différente" do
		  @m1 = Motif::new :notes => "a a a", :octave => 3
		  @m2 = Motif::new :notes => "b b b", :octave => 2
			(@m1 + @m2).to_s.should == "\\relative c { a a a b, b b }"
		end
		it ":to_s avec octave défini doit renvoyer la bonne valeur avec deux motifs d'octave définis" do
		  @m1 = Motif::new :notes => "a a a", :octave => 5
			@m2 = Motif::new :notes => "c c c", :octave => 3
			(@m1 + @m2).to_s(:octave => 1, :duree => 8).should ==
				"\\relative c,, { a8 a a c,,, c c }"
			# puts "\n@m2 : #{@m2.inspect}"
			# puts "\n@m1: #{@m1.inspect}"
			(@m2 + @m1).to_s(:octave => 1, :duree => 8).should ==
				"\\relative c,, { c8 c c a''' a a }"
		end
		
		it ":to_s avec une clé définie doit renvoyer la bonne valeur" do
		  mot = Motif::new :notes => "a b c d", :clef => "g"
			mot.to_s.should == "\\relative c' { \\clef \"treble\" a b c d }"
		end
		
		# :to_llp
		it "doit répondre à :to_llp" do
		  @m.should respond_to :to_llp
		end
		it ":to_llp doit retourner la bonne valeur" do
		  mo = Motif::new "c d e"
			mo.to_llp.should == "c d e"
			mo = Motif::new "do# sib la##"
			mo.to_llp.should == "cis bes aisis"
			iv_set(mo, :duration => 8)
			mo.to_llp.should == "cis8 bes aisis"
		end
		
		# :simple_notes
		it "doit répondre à :simple_notes" do
		  @m.should respond_to :simple_notes
		end
		it ":simple_notes doit retourner les notes simples" do
		  mo = Motif::new "c d e", :slured => true, :duree => "8"
			mo.simple_notes.should == "c d e"
		end
		
		# Contrôle des trois méthodes de retour des notes
		# 	simple_notes		
		# 		Les notes simples, sans durée, liaison, dynamique, etc.
		# 	to_llp					
		# 		Notes avec durée, liaison, dynamique, etc. mais sans relative
		# 	to_s		
		# 		Notes complètes, avec durée, liaisons, dynamique, etc.
		# 		et relative	=> égal à to_llp + relative
		it ":simples_notes, :to_llp et :to_s doivent retourner la bonne valeur" do
		  mo = Motif::new "c d e f", 
											:slured 		=> true, 
											:duree 			=> "8", 
											:crescendo 	=> true,
											:octave 		=> 1
			mo.simple_notes.should == "c d e f"
			mo.to_llp.			should == "c8(\\< d e f)\\!"
			mo.to_s.				should == "\\relative c,, { c8(\\< d e f)\\! }"
		end
		
		# set_octave
		it "doit répondre à :set_octave" do
		  @m.should respond_to :set_octave
		end
		it ":set_octave doit motidifier l'octave du motif" do
		  mo = Motif::new "c", :octave => 1
			mo.octave.should == 1
			mo.set_octave(4)
			mo.octave.should == 4
		end
		it ":set_octave doit rectifier l'octave des LINotes (if any)" do
		  mo = Motif::new "c d e c, d e'", :octave => 3
			mo.octave.should == 3
			explosion = mo.explode
			ln = explosion[0]
			ln.note.should == "c"
			ln.octave.should == 3
			ln.delta.should == 0
			mo.set_octave 0
			ln = explosion[0]
			ln.note.should == "c"
			ln.octave.should == 0
			ln = explosion[1]
			ln.note.should == "d"
			ln.octave.should == 0
		end
		# :set_clef
		it "doit répondre à :set_clef" do
		  @m.should respond_to :set_clef
		end
		it ":set_clef doit définir la clef à utiliser" do
		  iv_get(@m, :clef).should be_nil
			@m.set_clef "g"
			iv_get(@m, :clef).should == "treble"
			@m.set_clef "f"
			iv_get(@m, :clef).should == "bass"
			@m.set_clef "ut3"
			iv_get(@m, :clef).should == "alto"
			@m.set_clef "ut4"
			iv_get(@m, :clef).should == "tenor"
			@m.set_clef nil
			iv_get(@m, :clef).should be_nil
		end
		it ":set_clef doit lever une erreur en cas de mauvaise valeur" do
			err = detemp(Liby::ERRORS[:bad_clef], :clef => "bad")
		  expect{@m.set_clef("bad")}.to raise_error(SystemExit, err)
		end
		# :mark_clef
		it "doit répondre à :mark_clef" do
		  @m.should respond_to :mark_clef
		end
		it ":mark_clef doit renvoyer la bonne valeur" do
			@m.set_clef nil
			@m.mark_clef.should == ""
			@m.set_clef 'f'
			@m.mark_clef.should == "\\clef \"bass\" "
			@m.set_clef 'ut4'
			@m.mark_clef.should == "\\clef \"tenor\" "
			@m.set_clef 'g'
			@m.mark_clef.should == "\\clef \"treble\" "
			@m.set_clef nil
		end

		# -------------------------------------------------------------------
		# Opérations sur première note
		# -------------------------------------------------------------------
		describe "Opérations sur la première note" do
			# :first_note
			it "doit répondre à :first_note" do
			  @m.should respond_to :first_note
			end
			it ":first_note doit renvoyer un objet de class LINote" do
				mo = Motif::new "c e g"
				mo.first_note.class.should == LINote
			end
			it ":first_note (non strict) doit retourner la première note ou le silence" do
				[
					["c", 3, "c", 3],
					["<a c e>", 2, "a", 2],
					["r <b d fis>4 r c c", 1, "r", nil]
					# @todo: peut-être d'autres tests ici
				].each do |d|
					suite, octave_motif, first, octave_note = d
					mot = Motif::new(:notes => suite, :octave => octave_motif)
					first_note = mot.first_note
					first_note.with_alter.should == first
					first_note.octave.should == octave_note
					first_note.duration.should be_nil
				end
			end
			it ":first_note (strict) doit renvoyer la première note" do
				[
					["a ees c", 3, "a", 3],
					["a b c", 3, "a", 3],
					["r r aes b c", 3, "aes", 3],
					["<a c e>", 2, "a", 2],
					["r8 <b d fis>4 r c c", 1, "b", 1]
					# @todo: peut-être d'autres tests ici
				].each do |d|
					suite, octave_motif, first, octave_note = d
					mot = Motif::new(:notes => suite, :octave => octave_motif)
					first_note = mot.first_note(strict=true)
					first_note.with_alter.should == first
					first_note.octave.should == octave_note
					first_note.duration.should be_nil
				end
			end
			# :set_first_note
			it "doit répondre à :set_first_note" do
			  @m.should respond_to :set_first_note
			end
			it ":set_first_note doit recevoir une linote ou un string" do
				motif = Motif::new "c"
				ln 		= LINote::new "d"
			  expect{motif.set_first_note(ln)}.not_to raise_error
				expect{motif.set_first_note("d")}.not_to raise_error
				expect{motif.set_first_note(:duration => "4")}.to raise_error
			end
			it ":set_first_note ne doit rien faire si aucune note" do
			  motif = Motif::new ""
				ln = LINote::new "c"
				motif.set_first_note ln
				motif.to_llp.should == ""
			end
			it ":set_first_note(strict=false) doit définir la première note ou silence" do
			  mo = Motif::new "r c d e", :duration => 1
				ln = LINote::new "a", :duration => 4
				mo.set_first_note ln
				mo.to_llp.should == "a4 c1 d e"
			end
			it ":set_first_note(strict=true) doit définir la vraie note" do
			  mo = Motif::new "r c d e"
				ln = LINote::new "a", :duration => 4
				mo.set_first_note ln, strict = true
				mo.to_llp.should == "r4 a d e"
			end
			it ":set_first_note gère les durées (défini pour linote mais pas motif)" do
			  mo = Motif::new "r c d e"
				ln = LINote::new "a", :duration => 4
				mo.set_first_note ln, strict = true
				mo.to_llp.should == "r4 a d e"
			end
			it ":set_first_note gère les durées (défini pour linote et motif)" do
				mo = Motif::new "r c d e", :duration => 1
				ln = LINote::new "a", :duration => 4
				mo.set_first_note ln, strict = true
				mo.to_llp.should == "r1 a4 d1 e"
			end
		end # / fin describe opérations sur première note
		
		
		# :last_note et :real_last_note
		it "doit répondre à :last_note" do
		  @m.should respond_to :last_note
		end
		it "doit répondre à :real_last_note" do
		  @m.should respond_to :real_last_note
		end
		it ":last_note doit retourner un objet de type Note" do
			mo = Motif::new "c e g"
		  mo.last_note.class.should == LINote
		end
		ary_str = <<-DEFA
			suite						oct/N		last	real_last		oct_last
		-------------------------------------------------------------------
			c-d-e						3				e			e						3
			c-d-r						3				r			r						-
			a-b-c						2				c			c						3
			a-c-e						3				e			e						4
			<b-d-fis>				1				fis		fis					2
			d-<d-fis-a>8-r	2				r			r						-
			d-<d-fis-a>8		2				a			a						2
			d-<g-bb-d>4 	 	2				d			d						3
			d-<g-bb-d>4-r 	2				r			r						-
			d-d,-d,					1				d			d						-1
			d-d,-d,-r				1				r			r						-
			e-e'-f'					2				f			f						4
			d(-<d,-fis'-aeses,,>8-gis') 	2		gis		gis		2
			gis-aeses				3				aeses	aeses				3
		-------------------------------------------------------------------
		DEFA
		ary_str.to_array.each do |data|
			suite 				= data.delete(:suite).gsub(/-/, ' ')
			octave_motif 	= data.delete(:oct)
			last					= data.delete(:last)
			real_last			= data.delete(:real_last)
			octave_last		= data.delete(:oct_last)
			octave_last = octave_last.to_i unless octave_last.nil?
			it ":last_note (non strict) de « #{suite}»-oct:#{octave_motif} doit retourner #{last}-#{octave_last}" do
				$DEBUG = false
				begin
					mot = Motif::new(:notes => suite, :octave => octave_motif)
					last_note 			= mot.last_note(strict = false)
					real_last_note 	= mot.real_last_note( strict = false)
					raise if 			last_note.class						!= LINote \
										||	real_last_note.class			!= LINote \
					 					||	last_note.octave					!= octave_last \
										|| 	last_note.with_alter 			!= last \
										||	real_last_note.with_alter	!= real_last
				rescue
					if $DEBUG 
						$DEBUG = false
					else
						$DEBUG = true
						retry
					end
				end
				last_note.with_alter.should 			== last
				real_last_note.with_alter.should	== real_last
				last_note.octave.should						== octave_last
			end
		end
		
		ary_str = <<-DEFA
			suite						oct/N		last	real_last		oct_last/N
		-------------------------------------------------------------------
			c-d-e						3				e			e						3
			a-b-c						2				c			c						3
			a-c-e						3				e			e						4
			a-c-e-r-r				3				e			e						4
			<b-d-fis>				1				b			fis					1
			d-<d-fis-a>8-r	2				d			a						2
			d-<g-bb-d>4-r 	2				g			d						2
			d-d,-d,-r				1				d			d						-1
			e-e'-f'					2				f			f						4
			d(-<d,-fis'-aeses,,>8-gis')-r 	2		gis		gis		2
			gis-aeses				3				aeses	aeses				3
		-------------------------------------------------------------------
		DEFA
		ary_str.to_array.each do |data|
			suite 				= data.delete(:suite).gsub(/-/, ' ')
			octave_motif 	= data.delete(:oct)
			last					= data.delete(:last)
			real_last			= data.delete(:real_last)
			octave_last		= data.delete(:oct_last)
			it ":last_note (strict) de « #{suite}»-oct:#{octave_motif} doit retourner #{last}-#{octave_last}" do
				$DEBUG = false
				begin
					mot = Motif::new(:notes => suite, :octave => octave_motif)
					last_note 			= mot.last_note(strict=true)
					real_last_note 	= mot.real_last_note(strict=true)
					raise if 			last_note.class						!= LINote \
										||	real_last_note.class			!= LINote \
					 					||	last_note.octave					!= octave_last \
										|| 	last_note.with_alter 			!= last \
										||	real_last_note.with_alter	!= real_last
				rescue
					puts "\n\n### ERREUR CONTRÔLE DE LAST NOTE"
					puts "= motif: #{mot.inspect}"
					puts "  Construit à partir de :"
					puts "	- suite: #{suite}"
					puts "	- octave du motif: #{octave_motif}"
					puts "= Dernière attendue: #{last}-octave:#{octave_last}"
					puts "= Obtenu: #{real_last_note.inspect}"
					puts "======================================="
				end
				last_note.class.should 						== LINote
				real_last_note.class.should 			== LINote
				last_note.octave.should						== octave_last
				last_note.with_alter.should 			== last
				real_last_note.with_alter.should 	== real_last
			end
		end
		# :first_et_last_note
		it "doit répondre à :first_et_last_note" do
		  @m.should respond_to :first_et_last_note
		end
		[
			["c d e", "c", 4, "e", 4],
			["g a b", "g", 4, "b", 4],
			["b c d", "b", 4, "d", 5],
			["r c d e r", "c", 4, "e", 4],
			["r g a b r", "g", 4, "b", 4],
			["r b c d r", "b", 4, "d", 5],
			["c <c e g>", "c", 4, "c", 4],
			["c <e g c>", "c", 4, "e", 4],
			["r r aes b c", "aes", 4, "c", 5],
			["r a( b ces r)", "a", 4, "ces", 5],
			["r a( c <e g b d>) r r4", "a", 4, "e", 5]
		].each do |d|
			suite, firstexp, firstexp_oct, lastexp, lastexp_oct = d
			$DEBUG = false
			begin
				puts "\n\n$DEBUG ON" if $DEBUG
				first, last = Motif::new(suite).first_et_last_note(strict = true)
				texte = ":first_et_last_note avec motif «#{suite}» "
				texte << "doit renvoyer la 1ère note «#{firstexp}-#{firstexp_oct}» "
				texte << "et la dernière «#{lastexp}-#{lastexp_oct}»"
				raise if first.octave != firstexp_oct || last.octave != lastexp_oct
			rescue
				if $DEBUG == true
					$DEBUG = false
				else
					$DEBUG = true
					retry
				end
			end
			it texte do
				first.class.			should == LINote
				last.class.				should == LINote
				first.with_alter.	should == firstexp
				last.with_alter.	should == lastexp
				first.octave.			should == firstexp_oct
				last.octave.			should == lastexp_oct
			end
			$DEBUG = false if $DEBUG
		end
		
		# :change_durees_in_motif
		it "doit répondre à :notes_with_duree" do
		  @m.should respond_to :notes_with_duree
		end
		it ":notes_with_duree doit changer la durée des notes du motif" do
		  @m = Motif::new "a b c des e4"
			LINote::implode(@m.notes_with_duree(2)).should == "a2 b c des e4"
		end
		
		# :notes_with_liaison
		it "doit répondre à :notes_with_liaison" do
		  @m.should respond_to :notes_with_liaison
		end
		it ":notes_with_liaison doit retourner la bonne valeur" do
			suite = "a b c d e"
		  mo = Motif::new suite
			mo.notes_with_liaison.should == suite
			mo.slure
			res = mo.notes_with_liaison
			res.class.should 				== Array
			res.first.class.should 	== LINote
			res.first.legato.should == LINote::BIT_START_SLURE
			res.last.legato.should  == LINote::BIT_END_SLURE
			
			mo = Motif::new :notes => suite, :legato => true
			LINote::implode(mo.notes_with_liaison).should == "a\\( b c d e\\)"
		end
		
		# :notes_with_dynamique
		describe "Dynamique" do
			it "doit répondre à :set_crescendo" do
			  @m.should respond_to :set_crescendo
			end
			it ":set_crescendo doit régler la dynamique" do
			  motif = Motif::new "a b c"
				motif.set_crescendo true
				motif.get(:dynamique).should == {
					:start => '\<',
					:start_dyna => nil,
					:end 		=> '\!'
				}
			end
			it "doit répondre à :set_decrescendo" do
			  @m.should respond_to :set_decrescendo
			end
			it ":set_decrescendo doit régler la dynamique" do
			  motif = Motif::new "a b c"
				motif.set_decrescendo( true )
				motif.get(:dynamique).should == {
					:start => '\>', :start_dyna => nil, :end => '\!'
				}
			end
			it "doit répondre à :notes_with_dynamique" do
			  @m.should respond_to :notes_with_dynamique
			end
			it ":notes_with_dynamique doit retourner la bonne valeur" do
			  suite = "a b c d e"
				mo = Motif::new suite
				mo.notes_with_dynamique.should == suite
				mo.crescendo
				mo.notes.should == suite
				res = mo.notes_with_dynamique
				prem = res.first
				prem.dyna.should_not be_nil
				prem.dyna[:start].should be_true
				prem.dyna[:end].should be_false
				prem.dyna[:crescendo].should be_true
				last = res.last
				last.dyna[:end].should be_true
				last.dyna[:start].should be_false
				mo.notes.should == suite
			end
			it "un motif avec slure et dynamique doit retourner les bonnes notes" do
			  mo = Motif::new "a b c d e"
				mo.slure.crescendo
				# puts "\n\nmotif: #{mo.inspect}"
				mo.to_llp.should == "a(\\< b c d e)\\!"
			end
		end
		
		# :notes_with_triolet
		it "doit répondre à :notes_with_triolet" do
		  @m.should respond_to :notes_with_triolet
		end
		it ":notes_with_triolet doit retourner la bonne valeur" do
		  mo = Motif::new "a b c"
			mo.notes_with_triolet("a b c").should == "a b c"
			mo.triolet
			mo.notes_with_triolet("a b c").should == "\\times 2/3 { a b c }"
		end
		
		# :octave_from
		it "doit répondre à :octave_from" do
		  @m.should respond_to :octave_from
		end
		it ":octave_from doit renvoyer la bonne valeur" do
		  iv_set(@m, :octave => 2)
			@m.octave_from(2).should == 0
			@m.octave_from(4).should == 2
			@m.octave_from(0).should == -2
		end
	end
	
	describe "Transformation du motif" do
	  before(:each) do
	    @m = Motif::new "bb g f e,4 bb8"
	  end

		it "doit répondre à :as_motif" do
		  mo = Motif::new "a b"
			mo.should respond_to :as_motif
		end
		it ":as_motif doit retourner le motif" do
		  mo = Motif::new "a b"
			mo.as_motif.should == mo
		end
	
		# :+
		it "doit répondre à :+" do
		  repond_a :+
		end
		it ":+ permet d'additionner des motifs" do
		  @m1 = Motif::new "c d e"
			@m2 = Motif::new "f g a"
			(@m1 + @m2).to_s.should == "\\relative c' { c d e f g a }"
		end
		it ":+ transforme correctement @notes du nouveau motif" do
		  mo1 = Motif::new "c d e"
			mo2 = Motif::new "f g a"
			mo3 = mo1 + mo2
			mo1.notes.should == "c d e"
			mo3.notes.should == "c d e f g a"
			mo4 = mo1 + mo3
			mo4.notes.should == "c d e c d e f g a"
		end
		it ":+ doit avoir la valeur d'octave du premier motif" do
		  @m = Motif::new :notes => "a a a", :octave => 4
			iv_get(@m, :octave).should == 4
			m2 = Motif::new :notes => "b b b", :octave => -1
			iv_get(m2, :octave).should == -1
			m3 = (m2 + @m)
			iv_get(m3, :octave).should == -1
			m3 = (@m + m2)
			iv_get(m3, :octave).should == 4
		end
		# Note: le traitement de l'ajout d'un motif et d'une note est
		# traité dans le module de test des opérations d'addition
		
		it ":+ avec un type invalide doit lever une erreur fatale" do
			mo = Motif::new "c d e"
		  h = {:un => "un", :deux => "deux" }
			err = detemp(Liby::ERRORS[:cant_add_this], :classe => h.class.to_s)
			expect{mo + h}.to raise_error(SystemExit, err)
		end
		
		# :join 
		it "doit répondre à :join" do
		  mo = Motif::new("d f a")
			mo.should respond_to :join
			# LE TEST DU FONCTIONNEMENT SE FAIT AVEC LA MÉTHODE STATIQUE
			# LINote::join POUR NE PAS AVOIR À MULTIPLIER LES EXEMPLES
			# (cf. dans spec/class/linote_spec.rb)
		end
		
		# :*
		it "doit répondre à :*" do
		  repond_a :*
		end
		it ":* permet de multiplier des motifs" do
		  m1 = Motif::new "c e g"
			(m1 * 3).to_s.should == "\\relative c' { c e g c, e g c, e g }"
		end
		# @note: les autres opérations sont traitées dans le module
		# de tests operation/multiplication
		
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
		
		# :slured
		describe ":slure" do
			before(:each) do
			  @mo = Motif::new(:notes => "a b c d e")
			end
			it "doit exister" do
			  @mo.should respond_to :slured
			end
			it "doit définir la propriété @slured" do
				iv_get(@mo, :slured).should === false
			  @mo.slure
				iv_get(@mo, :slured).should === true
			end
			it "-d doit renvoyer un nouveau motif correct sans modifier l'original" do
			  iv_get(@mo, :slured).should == false
				new_mo = @mo.slured
				iv_get(@mo, :slured).should == false
				iv_get(new_mo, :slured).should === true
			end
			it "-d doit pouvoir être défini à l'instanciation" do
			  mo = Motif::new(:notes => "a b c d", :slured => true)
				iv_get(mo, :slured).should be_true
				mo.should be_slured
				mo.to_s.should == "\\relative c' { a( b c d) }"
			end
			it "-d à l'instanciation doit produire une erreur si impossible par le motif" do
				data = {:notes => "a b\\( c d( e)\\)", :slured => true}
			  expect{Motif::new(data)}.to raise_error(SystemExit)
			end
			it "doit retourner l'instance du motif" do
			  new_mo = @mo.slure
				new_mo.class.should == Motif
				new_mo.object_id.should == @mo.object_id
			end
			it "doit ajouter le slur au motif" do
			  @mo.to_s.should == "\\relative c' { a b c d e }"
				@mo.slure
				@mo.to_s.should == "\\relative c' { a( b c d e) }"
			end
			it "doit ajouter un « sur-slur » s'il existe déjà une liaison" do
			  mo = Motif::new "a b( c) d( e)"
				iv_get(mo, :legato).should  == false
				iv_get(mo, :slured).should  == false
				# La propriété @slured doit être false, mais le motif doit
				# répondre true à slured? par la suite de notes
				mo.should be_slured
				mo.to_s.should == "\\relative c' { a b( c) d( e) }"
				mo.slure
				iv_get(mo, :legato).should === true
				iv_get(mo, :slured).should == false
				mo.should be_slured
				mo.should be_legato
				mo.to_s.should == "\\relative c' { a\\( b( c) d( e)\\) }"
			end
			it "doit ajouter un « sur-slur » si le motif est marqué slured" do
			  mo = Motif::new "a b c d e"
				mo.slure
				iv_get(mo, :legato).should == false
				iv_get(mo, :slured).should === true
				mo.slure
				iv_get(mo, :legato).should === true
			end
			it "ne doit pas pouvoir être appliqué s'il y a déjà un sur-slur" do
				suite = "a b\\( c d\\)"
			  mo = Motif::new suite
				err = detemp(Liby::ERRORS[:motif_cant_be_surslured], :motif => suite)
				expect{mo.slure}.to raise_error(SystemExit, err)
				iv_get(mo, :legato).should  == false
				iv_get(mo, :slured).should  == false
			end
			it "ne doit pas pouvoir être appliqué si le motif est marqué legato" do
			  suite = "a b c d"
				mo 		= Motif::new suite
				mo.legato
				expect{mo.slure}.to raise_error(
					SystemExit, 
					Liby::ERRORS[:motif_legato_cant_be_slured])
				iv_get(mo, :legato).should  == true
				iv_get(mo, :slured).should  == false
			end
			it "? doit exister" do
			  @mo.should respond_to :slured?
			end
			it "? doit retourner la bonne valeur" do
			  mo = Motif::new "a b c d"
				mo.should_not be_slured
				mo.slure
				mo.should be_slured
				iv_set(mo, :slured => false)
				mo.should_not be_slured
				iv_set(mo, :notes => "a b c( d e)")
				mo.should be_slured
			end
		end
		
		# :legato
		describe ":legato" do
			it "doit exister" do 
				@m.should respond_to :legato
			end
			it "doit pouvoir être spécifié à l'instanciation" do
			  mo = Motif::new "a b c d e"
				mo.should_not be_legato
				mo = Motif::new :notes => "a b c d e", :legato => true
				mo.should be_legato
			end
			it "doit produire une erreur à l'instanciation si impossible" do
				data = {:notes => "a b c\\( b d\\)", :legato => true}
			  expect{Motif::new(data)}.to raise_error(SystemExit)
			end
			it ":legato doit renvoyer une instance du motif" do
			  @m.legato.class.should == Motif
			end
			it ":legato doit renvoyer une valeur modifiée" do
			  @mo = Motif::new "a b cis r4 a-^"
				res = @mo.legato
				res.to_s.should == "\\relative c' { a\\( b cis r4 a-^\\) }"
			end
			it ":legato avec :new => true doit renvoyer un nouveau motif" do
			  @mo = Motif::new "a b d"
				@mo.legato
				iv_get(@mo, :notes).should == "a b d"
				iv_get(@mo, :legato).should === true
			  @mo = Motif::new "a b d"
				@mo.legato(:new => true)
				iv_get(@mo, :legato).should === false
			end
			it "? doit exister" do
			  @m.should respond_to :legato?
			end
			it "? doit retourner la bonne valeur" do
			  mo = Motif::new "a b c d"
				mo.should_not be_legato
				mo.legato
				mo.should be_legato
				iv_set(mo, :legato => false)
				mo.should_not be_legato
				iv_set(mo, :notes => "a b c\\( d e\\)")
				mo.should be_legato
			end
		end

		# :triolet et changement de division de temps
		describe "Triolets et changement de division du temps" do
			it "doit répondre à :set_triolet / :set_triplet" do
			  @m.should respond_to :set_triolet
				@m.should respond_to :set_triplet
			end
			it ":set_triolet doit définir le triolet (avec argument true)" do
			  mo = Motif::new "a b c"
				mo.set_triolet(true)
				iv_get(mo, :triolet).should == "2/3"
			end
			it ":set_triolet doit définir le triolet (avec argument 2/3)" do
			  mo = Motif::new "a b c"
				mo.set_triolet("2/3")
				iv_get(mo, :triolet).should == "2/3"
			end
			it ":set_triolet doit lever une erreur en cas de mauvaise valeur" do
			  mo = Motif::new "b c d"
				err = detemp(Liby::ERRORS[:bad_value_for_triolet], 
											:bad => "bad", :notes => "b c d")
			  expect{mo.set_triolet("bad")}.to raise_error(SystemExit, err)
			end
			it ":set_triolet doit lever une erreur en cas de mauvais nombre de notes" do
			  mo = Motif::new "b c d e"
				err = detemp(Liby::ERRORS[:bad_nombre_notes_for_triolet], 
											:notes => mo.notes, :bad => "2/3")
				expect{mo.set_triolet(true)}.to raise_error(SystemExit, err)
			end
			it "doit répondre à :triolet / :triplet" do
			  @m.should respond_to :triolet
				@m.should respond_to :triplet
			end
			it ":triolet doit retourner le motif" do
			  mo = Motif::new "a b c"
				mo.triolet.class.should == Motif
			end
			it ":triolet doit transformer le motif en triolet" do
			  mo = Motif::new "a b c"
				iv_get(mo, :triolet).should be_nil
				new_mo = mo.triolet
				iv_get(new_mo, :triolet).should == "2/3"
				iv_get(mo, :triolet).should == "2/3"
				mo.to_s.should == "\\relative c' { \\times 2/3 { a b c } }"
			end
		end

		# :moins
		it "doit répondre à :moins" do repond_a :moins end
		it ":moins doit retourner l'objet" do
		  @m.moins(1).class.should == Motif
		end
		it ":moins doit donner le motif avec les demi-tons en moins" do
			iv_set(SCORE, :key => nil)
			@m = Motif::new "bb g f e,4 bb8"
		  @m.moins(1).to_s.should == "\\relative c' { a fis e ees,4 a8 }"
			@m.moins(2).to_s.should == "\\relative c' { aes f ees d,4 aes8 }"
			iv_set(SCORE, :key => 'G')
		  @m.moins(1).to_s.should == "\\relative c' { a fis e dis,4 a8 }"
			@m.moins(2).to_s.should == "\\relative c' { gis f dis d,4 gis8 }"
		end
		it ":moins doit respecter l'octave du motif" do
			notes = 'a fis e ees r'
		  mo = Motif::new :notes => notes, :octave => 0
			mo.moins(0).to_s.should == "\\relative c,,, { a fis e dis r }"
			mo = Motif::new :notes => notes, :octave => -2
			mo.moins(2).to_s.should == "\\relative c,,,,, { g e d cis r }"
		end
		it ":moins doit pouvoir spécifier l'octave explicitement" do
		  notes = "a fis r gis"
			mo = Motif::new :notes => notes, :octave => 3
			mo.to_s.should == "\\relative c { #{notes} }"
			res = mo.moins(0, :octave => 0).to_s
			res.should == "\\relative c,,, { #{notes} }"
			res = mo.moins(0, :octave => -2).to_s
			res.should == "\\relative c,,,,, { #{notes} }"
			res = mo.moins(2, :octave => 1).to_s
			p1 = "\\relative c,, { g e r fis }"
			p2 = "\\relative c,, { g e r ges }"
			[p1, p2].should include(res)
			
		end
		
		# :plus
		it "doit répondre à :plus" do repond_a :plus end
		it ":plus doit retourner l'objet" do
		  @m.plus(1).class.should == Motif
		end
		it ":plus doit donner le motif supérieur" do
			iv_set(SCORE, :key => nil)
		  @m.plus(1).to_s.should == "\\relative c' { b aes fis f,4 b8 }"
			@m.plus(2).to_s.should == "\\relative c' { c a g fis,4 c8 }"
			iv_set(SCORE, :key => 'Bb')
		  @m.plus(1).to_s.should == "\\relative c' { b aes ges f,4 b8 }"
			@m.plus(2).to_s.should == "\\relative c' { c a g ges,4 c8 }"
		end
		it ":plus avec le paramètre :new => false doit modifier l'objet" do
		  @motif = Motif::new "c d e"
			@motif.plus(1)
			iv_get(@motif, :notes).should == "c d e"
			@motif.plus(1, :new => false)
			iv_get(@motif, :notes).should == "des ees f"
		end
	
		# :crescendo
		it "doit répondre à :crescendo" do
		  repond_a :crescendo
		end
		it ":crescendo sans argument doit définir le motif simple" do
		  @motif = Motif::new "a b c"
			new_motif = @motif.crescendo(:new => true)
			@motif.to_s.should == "\\relative c' { a b c }"
			new_motif.to_s.should == "\\relative c' { a\\< b c\\! }"
			new_motif = @motif.crescendo
			@motif.to_s.should == "\\relative c' { a\\< b c\\! }"
		end
		it ":crescendo avec :start doit définir la dynamique de départ" do
		  @motif = Motif::new "a b c"
			@motif.crescendo(:start => 'pp', :end => 'ff')
			# puts "\n@motif: #{@motif.inspect}"
			@motif.to_s.should == "\\relative c' { \\pp a\\< b c \\ff }"
		end
		it ":crescendo avec :end doit définir la dynamique de fin" do
		  @motif = Motif::new "a b c"
			@motif.crescendo(:end => 'fff')
			@motif.to_s.should == "\\relative c' { a\\< b c \\fff }"
		end
		
		# :decrescendo
		it "doit répondre à :decrescendo" do
		  repond_a :decrescendo
		end
		it ":decrescendo sans argument doit définir le motif simple" do
		  @motif = Motif::new "a b c"
			new_motif = @motif.decrescendo(:new => true)
			@motif.to_s.should == "\\relative c' { a b c }"
			new_motif.to_s.should == "\\relative c' { a\\> b c\\! }"
			@motif.decrescendo(:new => false)
			@motif.to_s.should == "\\relative c' { a\\> b c\\! }"
		end
		it ":decrescendo avec :start doit définir la dynamique de départ" do
		  @motif = Motif::new "a b c"
			@motif.decrescendo(:new => false, :start => 'fff', :end => 'ppp')
			@motif.to_s.should == "\\relative c' { \\fff a\\> b c \\ppp }"
		end
		it ":decrescendo avec :end doit définir la dynamique de fin" do
		  @motif = Motif::new "a b c"
			@motif.decrescendo(:new => false, :end => 'ppp')
			@motif.to_s.should == "\\relative c' { a\\> b c \\ppp }"
		end
		
		
	end # / transformation du motif
end