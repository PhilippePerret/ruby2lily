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
			@m.octave.should == 3
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
		it "quand première note avec durée, on la prend" do
		  suite = "r1 r r r"
			mo = Motif::new suite
			mo.notes.should == "r r r r"
			mo.duration.should == "1"
			mo.to_s.should == "\\relative c { r1 r r r }"
		end
		it "<motif> doit répondre à :rationnalize_durees" do
		  mo = Motif::new "c d e"
			mo.should respond_to :rationnalize_durees
		end
		it ":rationnalize_durees doit rationnaliser les durées" do
			
		  mo = Motif::new "c1 d1"
			mo.notes.should == "c d"
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
			iv_get(mot, :octave).should == 3
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
				:octave => 3, 
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
				:octave => 3, :legato => false, :clef => "treble", 
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
			mo.octave.should == 3

			# Une suite "complète" de traitement de la note
			mo = Motif::new
			mo.set_with_string "do#4."
			mo.notes.should == "do#4."
			mo.duration.should == nil
			mo.any_notes_to_llp
			mo.notes.should == "cis4."
			mo.duration.should be_nil
			mo.rationnalize_durees
			mo.implode
			mo.notes.should == "cis"
			mo.duration.should == "4."
			mo.octave.should == 3
			
			mo = Motif::new
			mo.set_with_string "cbb( e4 g#) <c e g>8"
			mo.notes.should == "cbb( e4 g#) <c e g>8"
			mo.any_notes_to_llp
			mo.notes.should == "ceses( e4 gis) <c e g>8"
			mo.duration.should be_nil
			mo.octave.should == 3
		end
		
		# :set_with_hash
		it "doit répondre à :set_with_hash" do
		  @m.should respond_to :set_with_hash
		end
		it ":set_with_hash doit définir correctement le motif" do
		  @m.set_with_hash(:notes => "g e c", :duration => 8, :octave => -1)
			@m.notes.should == "g e c"
			@m.duration.should == "8"
			@m.octave.should == -1
		end
		it ":set_with_hash doit lever une erreur en cas de mauvais arguments" do
			def expected_error_with args, raison
				err = detemp(Liby::ERRORS[
					:invalid_arguments_pour_motif], 
					:args 	=> args.inspect,
					:raison => raison)
				expect{@m.set_with_hash(args)}.to raise_error(SystemExit, err)
			end
			# Pas un hash mais un string
			expected_error_with "string", Liby::ERRORS[:hash_required]
			# Hash vide
			expected_error_with( {}, Motif::ERRORS[:notes_undefined] )
			# Note invalide
			expected_error_with( {:notes => "h-^"}, Motif::ERRORS[:notes_non_lilypond] )
			# Mauvaise durée
			err = detemp(Liby::ERRORS[:bad_value_duree], :bad => 15 )
			expect{@m.set_with_hash(:notes => "c d e", :duration => 15)}.to \
				raise_error(SystemExit, err)
		end
		
		it "doit répondre à :set_octave_from_delta" do
		  @m.should respond_to :set_octave_from_delta
		end
		[
			["c' a d", nil, 4, "c' { c a d }"],
			["c, a d", nil, 2, "c, { c a d }"],
			["c' a d", 2, 3, "c { c a d }"],
			["r c' a d", 2, 3, "c { r c a d }"],
			["c,, a d", 2, 0, "c,,, { c a d }"],
			["r r4 c,, a d", 2, 0, "c,,, { r r4 c a d }"]
		].each do |d|
			suite, octave, oct_expected, res_expected = d
			texte = ":set_octave_from_delta pour « #{suite} » avec " \
							<< "octave #{octave} doit mettre l'octave à " \
							<< "#{oct_expected} et la suite à #{res_expected}"
			it texte do
			  # @note: on le vérifie à l'instanciation
				mo = Motif::new suite, :octave => octave
				mo.octave.should == oct_expected
				mo.to_s.should == "\\relative #{res_expected}"
				mo = Motif::new :notes => suite, :octave => octave
				mo.octave.should == oct_expected
				mo.to_s.should == "\\relative #{res_expected}"
			end
		end
		
		# :to_s
	  it "doit répondre à :to_s" do repond_a :to_s end
		it ":to_s doit renvoyer nil si le motif n'est pas défini" do
			iv_set(@m, :notes => nil)
		  @m.to_s.should be_nil
		end
		it ":to_s doit renvoyer le motif s'il est défini" do
		  iv_set(@m, :notes => "a b c")
			@m.to_s.should == "\\relative c { a b c }"
		end
		it ":to_s doit renvoyer le motif avec une durée si elle est définie" do
		  iv_set(@m, :notes => "c d e")
			@m.to_s(1).should == "\\relative c { c1 d e }"
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
			(@m2 + @m1).to_s(:octave => 1, :duree => 8).should ==
				"\\relative c,, { c8 c c a''' a a }"
		end
		
		it ":to_s avec une clé définie doit renvoyer la bonne valeur" do
		  mot = Motif::new :notes => "a b c d", :clef => "g"
			mot.to_s.should == "\\relative c { \\clef \"treble\" a b c d }"
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
				["r <b d fis>4 r c c", 1, "r", 1]
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
			suite						oct/N		last	real_last		oct_last/N
		-------------------------------------------------------------------
			c-d-e						3				e			e						3
			c-d-r						3				r			r						3
			a-b-c						2				c			c						3
			a-c-e						3				e			e						4
			<b-d-fis>				1				b			fis					1
			d-<d-fis-a>8-r	2				r			r						2
			d-<d-fis-a>8		2				d			a						2
			d-<g-bb-d>4 	 	2				g			d						2
			d-<g-bb-d>4-r 	2				r			r						2
			d-d,-d,					1				d			d						-1
			d-d,-d,-r				1				r			r						-1
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
			it ":last_note (non strict) de « #{suite}»-oct:#{octave_motif} doit retourner #{last}-#{octave_last}" do
				$DEBUG = false
				begin
					mot = Motif::new(:notes => suite, :octave => octave_motif)
					last_note 			= mot.last_note(strict = false)
					real_last_note 	= mot.real_last_note( strict = false)
					raise if 			last_note.class						!= LINote \
										||	real_last_note.class			!= LINote \
					 					||	last_note.octave 					!= octave_last \
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
				last_note.octave.should 					== octave_last
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
					 					||	last_note.octave 					!= octave_last \
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
				last_note.octave.should 					== octave_last
			end
		end
		# :first_et_last_note
		it "doit répondre à :first_et_last_note" do
		  @m.should respond_to :first_et_last_note
		end
		[
			["c d e", "c", 3, "e", 3],
			["g a b", "g", 3, "b", 3],
			["b c d", "b", 3, "d", 4],
			["r c d e r", "c", 3, "e", 3],
			["r g a b r", "g", 3, "b", 3],
			["r b c d r", "b", 3, "d", 4],
			["c <c e g>", "c", 3, "c", 3],
			["c <e g c>", "c", 3, "e", 3],
			["r r aes b c", "aes", 3, "c", 4],
			["r a( b ces r)", "a", 3, "ces", 4],
			["r a( c <e g b d>) r r4", "a", 3, "e", 4]
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
			@m.notes_with_duree(2).should == "a2 b c des e4"
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
			mo.notes_with_liaison.should == "a( b c d e)"
			mo.notes_with_liaison("a b c").should == "a( b c)"
			
			mo = Motif::new :notes => suite, :legato => true
			mo.notes_with_liaison.should == "a\\( b c d e\\)"
			mo.notes_with_liaison("b c").should == "b\\( c\\)"
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
			(@m1 + @m2).to_s.should == "\\relative c { c d e f g a }"
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
			(m1 * 3).to_s.should == "\\relative c { c e g c, e g c, e g }"
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
				mo.to_s.should == "\\relative c { a( b c d) }"
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
			  @mo.to_s.should == "\\relative c { a b c d e }"
				@mo.slure
				@mo.to_s.should == "\\relative c { a( b c d e) }"
			end
			it "doit ajouter un « sur-slur » s'il existe déjà une liaison" do
			  mo = Motif::new "a b( c) d( e)"
				iv_get(mo, :legato).should  == false
				iv_get(mo, :slured).should  == false
				# La propriété @slured doit être false, mais le motif doit
				# répondre true à slured? par la suite de notes
				mo.should be_slured
				mo.to_s.should == "\\relative c { a b( c) d( e) }"
				mo.slure
				mo.to_s.should == "\\relative c { a\\( b( c) d( e)\\) }"
				iv_get(mo, :legato).should === true
				iv_get(mo, :slured).should == false
				mo.should be_slured
				mo.should be_legato
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
				res.to_s.should == "\\relative c { a\\( b cis r4 a-^\\) }"
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
				mo.to_s.should == "\\relative c { \\times 2/3 { a b c } }"
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
		  @m.moins(1).to_s.should == "\\relative c { a fis e ees,4 a8 }"
			@m.moins(2).to_s.should == "\\relative c { aes f ees d,4 aes8 }"
			iv_set(SCORE, :key => 'G')
		  @m.moins(1).to_s.should == "\\relative c { a fis e dis,4 a8 }"
			@m.moins(2).to_s.should == "\\relative c { gis f dis d,4 gis8 }"
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
		  @m.plus(1).to_s.should == "\\relative c { b aes fis f,4 b8 }"
			@m.plus(2).to_s.should == "\\relative c { c a g fis,4 c8 }"
			iv_set(SCORE, :key => 'Bb')
		  @m.plus(1).to_s.should == "\\relative c { b aes ges f,4 b8 }"
			@m.plus(2).to_s.should == "\\relative c { c a g ges,4 c8 }"
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
			new_motif = @motif.crescendo
			@motif.to_s.should == "\\relative c { a b c }"
			new_motif.to_s.should == "\\relative c { a\\< b c\\! }"
			new_motif = @motif.crescendo(:new => false)
			@motif.to_s.should == "\\relative c { a\\< b c\\! }"
		end
		it ":crescendo avec :start doit définir la dynamique de départ" do
		  @motif = Motif::new "a b c"
			@motif.crescendo(:new => false, :start => 'pp', :end => 'ff')
			@motif.to_s.should == "\\relative c { \\pp a\\< b c \\ff }"
		end
		it ":crescendo avec :end doit définir la dynamique de fin" do
		  @motif = Motif::new "a b c"
			@motif.crescendo(:new => false, :end => 'fff')
			@motif.to_s.should == "\\relative c { a\\< b c \\fff }"
		end
		
		# :decrescendo
		it "doit répondre à :decrescendo" do
		  repond_a :decrescendo
		end
		it ":decrescendo sans argument doit définir le motif simple" do
		  @motif = Motif::new "a b c"
			new_motif = @motif.decrescendo
			@motif.to_s.should == "\\relative c { a b c }"
			new_motif.to_s.should == "\\relative c { a\\> b c\\! }"
			@motif.decrescendo(:new => false)
			@motif.to_s.should == "\\relative c { a\\> b c\\! }"
		end
		it ":decrescendo avec :start doit définir la dynamique de départ" do
		  @motif = Motif::new "a b c"
			@motif.decrescendo(:new => false, :start => 'fff', :end => 'ppp')
			@motif.to_s.should == "\\relative c { \\fff a\\> b c \\ppp }"
		end
		it ":decrescendo avec :end doit définir la dynamique de fin" do
		  @motif = Motif::new "a b c"
			@motif.decrescendo(:new => false, :end => 'ppp')
			@motif.to_s.should == "\\relative c { a\\> b c \\ppp }"
		end
		
		
	end # / transformation du motif
end