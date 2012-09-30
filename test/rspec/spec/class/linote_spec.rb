# 
# Tests de la classe LINote
# 
require 'spec_helper'
require 'linote'

describe LINote do
	before(:all) do
	  SCORE = Score::new unless defined? SCORE
		ORCHESTRE = Orchestre::new unless defined? ORCHESTRE
	end
	# -------------------------------------------------------------------
	# 	Classe
	# -------------------------------------------------------------------
  describe "La classe" do
		it "doit définir la constante ALTERS_PER_TUNE" do
		  defined?(LINote::ALTERS_PER_TUNE).should be_true
		end
		it "ALTERS_PER_TUNE doit contenir les bonnes valeurs" do
		  LINote::ALTERS_PER_TUNE['B'].should == {
				:nombre => 5, :suite => LINote::SUITE_DIESES, :add => 'is'
			}
		end
		it "doit définir la constante SUITE_DIESES" do
		  defined?(LINote::SUITE_DIESES).should be_true
		end
		it "SUITE_DIESES doit être valide" do
		  LINote::SUITE_DIESES.should == ['f', 'c', 'g', 'd', 'a', 'e', 'b']
		end
		it "doit définir la constante SUITE_BEMOLS" do
		  defined?(LINote::SUITE_BEMOLS).should be_true
		end
		it "SUITE_BEMOLS doit être valide" do
		  LINote::SUITE_BEMOLS.should == ['b', 'e', 'a', 'd', 'g', 'c', 'f']
		end
		it "doit définir la constante LISTE_ALT_TO_ALT_SIMPLE" do
		  defined?(LINote::LISTE_ALT_TO_ALT_SIMPLE).should be_true
		end
		it "LISTE_ALT_TO_ALT_SIMPLE doit définir les valeurs" do
			# On ne teste que quelques valeurs
		  LINote::LISTE_ALT_TO_ALT_SIMPLE["eeses"].should == "d"
			LINote::LISTE_ALT_TO_ALT_SIMPLE["fisis"].should == "g"
			LINote::LISTE_ALT_TO_ALT_SIMPLE["eisis"].should == "fis"
		end
		it "doit définir la constante GAMME_CHROMATIQUE" do
		  defined?(LINote::GAMME_CHROMATIQUE).should be_true
			LINote::GAMME_CHROMATIQUE.count.should == 12
			LINote::GAMME_CHROMATIQUE.should include 'cis'
		end
		it "doit définir la constante GAMME_CHROMATIQUE_BEMOLS" do
		  defined?(LINote::GAMME_CHROMATIQUE_BEMOLS).should be_true
			LINote::GAMME_CHROMATIQUE_BEMOLS.count.should == 12
			LINote::GAMME_CHROMATIQUE_BEMOLS.should include 'des'
		end
		it "doit définir la constante GAMME_DIATONIQUE" do
		  defined?(LINote::GAMME_DIATONIQUE).should be_true
			LINote::GAMME_DIATONIQUE.should include "g"
		end
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
		
		#  ALTERATIONS
		it "doit définir la constante ALTERATIONS" do
		  defined?(LINote::ALTERATIONS).should be_true
		end
		it "ALTERATIONS doit définir les bonnes valeurs" do
		  {'#' => 'is', '##' => 'isis', 'b' => 'es', 'bb' => 'eses'
			}.each do |str, str_llp|
				LINote::ALTERATIONS[str].should == str_llp
			end
		end
		
		# REG_ITAL_TO_LLP
		it "doit définir REG_ITAL_TO_LLP" do
		  defined?(LINote::REG_ITAL_TO_LLP).should be_true
		end
		
		# REG_NOTE_COMPLEXE
		it "doit définir REG_NOTE_COMPLEXE" do
		  defined?(LINote::REG_NOTE_COMPLEXE).should be_true
		end
		
		# REG_CHORD
		it "doit définir la constante REG_CHORD" do
		  defined?(LINote::REG_CHORD).should be_true
		end
		it "REG_CHORD doit permettre de repérer un accord" do
		 	res = "<a c e>".scan(/#{LINote::REG_CHORD}/)
			res.should_not be_empty
			res[0][0].should == "<a c e>"
			res = "ees c4 <aeses cis r> c c".scan(/#{LINote::REG_CHORD}/)
			res.should_not be_empty
			res[0][0].should == "<aeses cis r>"
			res = "c <d e f> <r a bes> c e".scan(/#{LINote::REG_CHORD}/)
			res.should_not be_nil
			res.should == [["<d e f>"], ["<r a bes>"]]
		end
		it "REG_CHORD ne doit pas se méprendre avec un crescendo" do
		  "<! c e a c e>".scan(/#{LINote::REG_CHORD}/).should be_empty
		end
		
		# :alterations_notes_in_key
		it "doit répondre à :alterations_notes_in_key" do
		  LINote.should respond_to :alterations_notes_in_key
		end
		it ":alterations_notes_in_key doit retourner le bon résultat" do
		  LINote::alterations_notes_in_key('C').should == {
				'c'=>'c', 'd'=>'d', 'e'=>'e', 'f'=>'f', 'g'=>'g', 'a'=>'a', 'b'=>'b'
			}
			LINote::alterations_notes_in_key('B').should == {
				'c'=>'cis', 'd'=>'dis', 'e'=>'e', 'f'=>'fis', 'g'=>'gis', 
				'a'=>'ais', 'b'=>'b'
			}
			LINote::alterations_notes_in_key('Db').should == {
				'c'=>'c', 'd'=>'des', 'e'=>'ees', 'f'=>'f', 'g'=>'ges', 'a'=>'aes',
				'b'=>'bes'
			}
			LINote::alterations_notes_in_key('Bb').should == {
				'c'=>'c', 'd'=>'d', 'e'=>'ees', 'f'=>'f', 'g'=>'g', 'a'=>'a', 
				'b'=>'bes'
			}
		end
		# :data_notes
		it "doit répondre à :explode" do
		  LINote.should respond_to :explode
		end
		# :implode
		it "doit répondre à :implode" do
		  LINote.should respond_to :implode
			# @note: la méthode est vérifiée ci-dessous
		end
		
		describe ":explode et :implode" do
			def compare_notes_et_data notes, data_comp
				liste_linotes = LINote::explode notes
				# puts "\n\n=== liste_linotes: #{liste_linotes.inspect}"
				nombre_linotes = liste_linotes.count
				(0..nombre_linotes-1).each do |i_linote|
					linote 	= liste_linotes[i_linote]
					comp		= data_comp[i_linote]
					comp.each do |prop, val|
						val = "" if prop == :post && val.nil?
						prop_value = linote.get prop.to_sym
						if prop_value != val
							puts "\n# COMPARAISON LINOTE ET DONNÉES NE MATCHE PAS (sur la propriété #{prop}):"
							puts "linote.#{prop}: #{prop_value}:#{prop_value.class}"
							puts "expected: #{val}:#{val.class}"
							puts "Suite : #{notes}"
							puts "Note d'indice : #{i_linote}"
							puts "Linote: #{linote.inspect}"
							puts "Data comparées : #{comp.inspect}"
							prop_value.should == val
						end
					end
				end
			end
		
			liste_tests = []
			
			# Simple note
			notes = "c"
			comp = [
				{:note => "c", :pre => nil, :post => nil, :jeu => nil, :duration => nil, :alter => nil}]
			liste_tests << [notes, comp]
		
			# Simple silence
			notes = "r"
			comp = [
				{:note => "r", :pre => nil, :post => nil, :jeu => nil, :duration => nil, :alter => nil}]
		  liste_tests << [notes, comp]
			
			# Notes simples avec liaison
			notes = "c( disis e8. fes)"
			comp_str = <<-DEFA
				note	pre		jeu		duration		alter		duree_post
			--------------------------------------------------
				c			-			-			-				-				-
				d			-			-			-				isis		-
				e			-			-			8.			-				-
				f			-			-			-				es			-
			--------------------------------------------------
			DEFA
			comp = comp_str.to_array
			liste_tests << [notes, comp]
			
			# Notes et accords
			notes = "ces <a c'' eeses,,>8 e <gis bes>156. r4."
			dpo = "duree_post"
			ollp = "delta/N"
			comp_str = <<-DEFA
				note	pre		jeu		duration		alter		#{dpo} #{ollp}
				--------------------------------------------------			
				c			-			-			-		 		 		es			-				-
				a			<			-			-		 		 		-				-				-
				c			-			-			-		 		 		-				-				2
				e			-			-			-		 		 		eses		8				-2
				e			-			-			-		 		 		-				-				-
				g			<			-			-		 		 		is			-				-
				b			-			-			-		 		 		es			156.		-
				r 		-			-			4.	 		 		-				-				-
			--------------------------------------------------			
			DEFA
			comp = comp_str.to_array
			liste_tests << [notes, comp]
		
			liste_tests.each do |donne|
				it "doivent fonctionner pour #{donne[0]}" do
					compare_notes_et_data donne[0], donne[1]
				end
			end


			it ":implode doit accepter des Strings et les écrire tels quels" do
			  motif = Motif::new "c d e f g a b"
				ary = motif.explode + ["||"]
				LINote::implode(ary).should == "c d e f g a b ||"
			end
			
		end #/ describe :implode et :explode
		
		# Test des propriétés d'octaves affectés par :explode
		[
			# suite				liste des notes obtenues
			# 						note, octave, delta
			["c",					[ 'c 4 0' ] ],
			["a c",				[ 'a 4 0', 'c 5 0'] 		],
			# Deltas
			["c,",				['c 3 0']									],
			["cis'",			['c 5 0']									],
			["a c,",			[ 'a 4 0', 'c 4 -1'] 		],
			["a c'' g,",	[ 'a 4 0', 'c 7 2', 'g 5 -1'] ],
			["c, g'",			['c 3 0', 'g 3 1']			],
			# Accords
			["a b, c, <g'' bis,>", 
					['a 4 0', 'b 3 -1', 'c 3 -1', 'g 4 2', 'b 3 -1']],
			["<a b c> e",	['a 4 0', 'b 4 0', 'c 5 0', 'e 4 0']],
			["<c e g> <c e g>", ['c 4 0', 'e 4 0', 'g 4 0', 'c 4 0', 'e 4 0', 'g 4 0']],
			["<a b> <c, d> <g' f> a,,", ['a 4 0', 'b 4 0', 'c 4 -1', 'd 4 0', 'g 4 1', 'f 4 0', 'a 2 -2']],

			# Dernier (pour la virgule)
			["c", ['c 4 0']]
		].each do |d|
			suite, expected = d
			it ":explode doit affecter les bons octaves pour la suite «#{suite}»" do
			  linotes = LINote::explode suite
				linotes.count.times do |i|
					linote		= linotes[i]
					note, oct, delta, real_oct = expected[i].split(' ')
					errors = []
					errors << "= La note #{linote.note} devrait être #{note}" \
						unless linote.note == note
					errors << "= L'octave attendu est #{oct}, linote.octave est : #{linote.octave}" \
						unless linote.octave == oct.to_i
					errors << "= Le delta attendu est #{delta}, linote.delta est : #{linote.delta}" \
						unless linote.delta == delta.to_i
					unless errors.empty?
						puts "\n\nERREUR AFFECTATION OCTAVES (#{__FILE__}:#{__LINE__})"
						puts "= Suite : #{suite}"
						puts "= Liste des linotes : #{linotes.inspect}"
						puts "= Linote courante (index #{i}) : #{linote.inspect}"
						puts errors.join("\n")
						linote.note.should 				== note
						linote.octave.should 			== oct.to_i
						linote.delta.should 			== delta.to_i
					end
				end
			end
		end

		# :llp_to_linote
		# ---------------
		# @note : c'est la méthode principale de détection d'une note
		# lilypond, on s'en sert donc pour valider toutes les formes
		# acceptables par ruby2lily (cf. plus bas)
		it "doit répondre à :llp_to_linote" do
		  LINote.should respond_to :llp_to_linote
		end
		it ":llp_to_linote doit retourner une Linote d'après un string llp" do
		  res = LINote::llp_to_linote("a")
			res.class.should == LINote
		end
		olp = "mark_delta"
		d   = "delta/N"
		fi	= "finger"
		ary_bonnes_valeurs = <<-DEFH
				suite		note alter duree #{d} #{olp} jeu #{fi}
			-------------------------------------------------------------------
				a				a			-			-			0			-			-		-
				aes			a			es		-			0			-			-		-
				aeses		a			eses	-			0			-			-		-
				a'			a			-			-			1			'			-		-
				a,			a			-			-			-1		,			-		-
				aes''		a			es		-			2			''		-		-
				aisis,,	a			isis	-			-2		,,		-		-
				a8			a			-			8			0			-			-		-
				a8.			a			-			8.		0			-			-		-
				aes,8..	a			es		8..		-1		,			-		-				
				a~			a			-			~			0			-			-		-
				a-^			a			-			-			-			-			^		-
				a4-^-4	a			-			-			-			-			^		4
				a4.-.-4	a			-			4.		-			-			.		4
				c-.^		c			-			-			-			-			.^	-
				# La totale
				aes'4.~-^-5	a	es		4.~		1			'			^		5
			-------------------------------------------------------------------
		DEFH
		ary_bonnes_valeurs.to_array.each do |data_llp|
			suite = data_llp.delete(:suite)
			data_llp[:mark_delta] = "" if data_llp[:mark_delta].nil?
			it "LINote::llp_to_linote('#{suite}') doit retourner : #{data_llp.inspect}" do
				linote = LINote::llp_to_linote(suite)
				linote.class.should == LINote
				[:note, :alter, :delta, :jeu, :finger].each do |prop|
					iv_get(linote, prop).should == data_llp[prop]
				end
				linote.mark_delta.should == data_llp[:mark_delta]
			end
		end

		it ":llp_to_linote doit lever une erreur si mauvais argument" do
			err = detemp(Liby::ERRORS[:bad_type_for_args], :good => "String",
						:bad => "Hash", :method => "LINote::llp_to_linote")
		  expect{LINote::llp_to_linote({})}.to raise_error(SystemExit, err)
			motif = Motif::new "a c d"
			err = detemp(Liby::ERRORS[:bad_type_for_args], :good => "String",
						:bad => "Motif", :method => "LINote::llp_to_linote")
		  expect{LINote::llp_to_linote(motif)}.to raise_error(SystemExit, err)
			
		end
		["str", "t-^" "aa("].each do |bad_llp|
			it ":llp_to_linote doit lever une erreur avec « #{bad_llp} »" do
				err = detemp(Liby::ERRORS[:not_note_llp], :note => bad_llp)
		  	expect{LINote::llp_to_linote(bad_llp)}.to raise_error(SystemExit, err)
			end
		end
		
		it "doit répondre à :extract_post_values" do
		  LINote.should respond_to :extract_post_values
		end
		it "doit répondre à :extract_dynamique_values" do
		  LINote.should respond_to :extract_dynamique_values
		end
		[
			["(",  				[LINote::BIT_START_SLURE, ""]], 
			[")",  				[LINote::BIT_END_SLURE, ""]], 
			["\\(",  			[LINote::BIT_START_LEGATO, ""]],
			["\\)",  			[LINote::BIT_END_LEGATO, ""]],
			["\\((",			[LINote::BIT_START_SLURE|LINote::BIT_START_LEGATO, ""]],
			[")\\)",			[LINote::BIT_END_SLURE|LINote::BIT_END_LEGATO, ""]],
			["(\\!", 			[LINote::BIT_START_SLURE, "\\!"], {:end 	=> true}],
			[")\\<", 			[LINote::BIT_END_SLURE, "\\<"], {:start => true, :crescendo => true}],
			["\\<)", 			[LINote::BIT_END_SLURE, "\\<"], {:start => true, :crescendo => true}],
			["\\)\\>--", 	[LINote::BIT_END_LEGATO, "\\>--"], {:start => true, :crescendo => false}],
			["\\>--\\)", 	[LINote::BIT_END_LEGATO, "\\>--"], {:start => true, :crescendo => false}]
		].each do |d|
			post, expected, dyna = d
			it ":extract_post_values('#{post}') doit renvoyer #{expected.inspect}" do
				# Rappel : la valeur renvoyée est un array qui contient :
				# 	[value pour @legato, value pour @dyna, new value pour @post]
			  LINote::extract_post_values(post).should == expected
			end
			it ":extract_dynamique_values('#{expected}') doit retourner #{dyna.inspect}" do
				unless dyna.nil?
			  	LINote::extract_dynamique_values(expected[1]).should == dyna
				end
			end
		end
		
		
		# :to_llp
		it "doit répondre à :to_llp" do
		  LINote::should respond_to :to_llp
		end
		it ":to_llp doit renvoyer un string de notes LilyPond" do
		  {
				"c#" 						=> "cis",
				"c##"						=> "cisis",
				"db"						=> "des",
				"dbb"						=> "deses",
				"bb" 						=> "bes",
				"e# fb" 				=> "eis fes",
				"ges b#" 				=> "ges bis",
				"b# bbb bb cis" => "bis beses bes cis",
				"ré#" 					=> "dis",
				"reb"						=> "des",
				"cis bb fa# fais"	=> "cis bes fis fis",
				"c r d"					=> "c r d"
			}.each do |str, str_llp|
				LINote::to_llp(str).should == str_llp
			end
		end
		
		# :join
		it "doit répondre à :join" do
		  LINote.should respond_to :join
		end
		it ":join peut recevoir seulement des Motifs" do
			mo1 = Motif::new( :notes => "c e g", :octave => 2)
			mo2 = Motif::new( :notes => "g e c", :octave => 2)
			expect{LINote::join( h1, h2 )}.not_to raise_error(SystemExit)
			err = detemp(Liby::ERRORS[:bad_type_for_args], {
				:good => "Motif", :bad => "String", :method => "LINote::join"
			})
			expect{LINote::join("bad","mauvais")}.to raise_error(SystemExit,err)

			err = detemp(Liby::ERRORS[:bad_type_for_args], {
				:good => "Motif", :bad => "Hash", :method => "LINote::join" })
			h1 = {:notes => "c e g", :octave => 3 }
			h2 = {:notes => "c e g", :octave => 3 }
		  expect{LINote::join( h1, h2 )}.to raise_error(SystemExit, err)
		  
		end
		[
		# 	mot 1  oct  mot 2  oct résultat attendu
		# -------------------------------------------------------------------
			# Essai motifs simples
			["c e g", 3, "c e g", 3, "c e g c, e g"],
			["d f a", 3, "d f a", 3, "d f a d, f a"],
			["d f a", 3, "d f a", 4, "d f a d f a"],
			["d f a", 3, "d f a", 5, "d f a d' f a"],
			["d f a", 3, "d f a", 2, "d f a d,, f a"],
			
			# Essais motifs complexes
			["ces( ees ges) r", 3, "c e g", 3, "ces( ees ges) r c, e g"],
			["ces( ees ges) r", 3, "c e g", 4, "ces( ees ges) r c e g"],
			["ces( ees ges) r", 3, "c e g", 2, "ces( ees ges) r c,, e g"],
			["ces( ees ges) r", 3, "c e g", 1, "ces( ees ges) r c,,, e g"],					
		].each do |data|
			notes1, oct_1, notes2, oct_2, expected = data
			mo1 = Motif::new(:notes => notes1, :octave => oct_1)
			mo2 = Motif::new(:notes => notes2, :octave => oct_2)
			result = expected
			mess = "::join avec Motif#«notes=#{notes1} octave=#{oct_1}» et " \
						<< "Motif#«notes=#{notes2} octave=#{oct_2}» doit produire #{expected}"
			it mess do
				res = LINote::join(mo1, mo2)
				unless res == expected
					# = débug =
					puts "\n\n### PROBLÈME DANS LINote::join :"
					puts "= Motif 1: #{mo1.inspect}"
					puts "= Motif 2: #{mo2.inspect}"
					puts "= Last note Motif 1: #{mo1.last_note(true).inspect}"
					puts "= First note Motif 2: #{mo2.first_note(true).inspect}"
					puts "= Notes attendues : #{expected}"
					puts "= Résultat obtenu: #{res.inspect}"
					# = / débug =
				end
				res.should == expected
				# On en profite pour vérifier aussi la méthode <motif>.join(<autre motif>)
				new_mo = mo1.join(mo2, :new => true)
				new_mo.notes.should 	== expected
				mo1.notes.should_not 	== expected
				mo1.join(mo2, :new => false)
				mo1.notes.should == expected
			end
		end
		
			
		# :delta_from_markdelta
		it "doit répondre à :delta_from_markdelta" do
		  LINote.should respond_to :delta_from_markdelta
		end
		it ":delta_from_markdelta doit renvoyer la bonne valeur" do
			LINote::delta_from_markdelta("").should  == 0
			LINote::delta_from_markdelta(nil).should == 0
		  LINote::delta_from_markdelta("'").should == 1
			LINote::delta_from_markdelta(",").should == -1
			LINote::delta_from_markdelta("''").should == 2
			LINote::delta_from_markdelta(",,").should == -2
			LINote::delta_from_markdelta("''''''''").should == 8
			LINote::delta_from_markdelta(",,,,,,,,").should == -8
		end
		
		# :mark_delta
		it "doit répondre à :mark_delta" do
		  LINote.should respond_to :mark_delta
		end
		it ":mark_delta doit retourner la bonne valeur" do
		  LINote::mark_delta(3).should == "'''"
			LINote::mark_delta(-3).should == ",,,"
			LINote::mark_delta(0).should == ""
			LINote::mark_delta(-4).should == ",,,,"
		end
		
		# :REG_NOTE
		it "doit définir REG_NOTE (motif pour trouver les notes)" do
		  defined?(LINote::REG_NOTE).should be_true
		end
		
  end # / classe
	describe "Méthodes de classe" do
		describe "Dépôt :pre / :post sur première ou dernière note" do
			# :pre_first_note
			it "doit répondre à :pre_first_note" do
			  LINote.should respond_to :pre_first_note
			end
			it ":pre_first_note doit pouvoir recevoir un string" do
			  expect{LINote::pre_first_note("a b c", '<')}.not_to raise_error
			end
			it ":pre_first_note doit pouvoir recevoir une liste de LINotes" do
				ary_ln = [LINote::new("a"), LINote::new("b")]
			  expect{LINote::pre_first_note(ary_ln, '<')}.not_to raise_error
			end
			it ":pre_first_note doit retourner une liste de LINotes" do
			  res = LINote::pre_first_note("a b c", '<')
				res.class.should == Array
				res.first.class.should == LINote
			end
			it ":pre_first_note doit ajouter un signe AVANT un pré existant" do
			  ary = LINote::pre_first_note("a b c", '<')
				res = LINote::pre_first_note( ary, '\fff ' )
				res.class.should == Array
				res.first.class.should == LINote
				res.first.pre.should_not == '<\fff '
				res.first.pre.should == '\fff <'
			end
			it ":pre_first_note ne doit pas poser le signe sur un silence" do
				sig = '<'
			  res = LINote::pre_first_note("r r r a b c", sig)
				res.first.pre.should_not == sig
				res[3].pre.should == sig
			end
			
			# :post_first_and_last_note
			it "doit répondre à :post_first_and_last_note" do
			  LINote.should respond_to :post_first_and_last_note
			end
			previous_suite = nil
			[
				["a b c d", '(', ')', "a( b c d)"],
				[nil, '\(', '\)', "a\\( b c d\\)"],
				[nil, '\<', '\!', "a\\< b c d\\!"],
				["aeses,8-^ b c disis''-.", '(', ')', "aeses-^( b c disis''-.)"]
						# @note: dans ce dernier cas, la durée "8" disparait puisque
						# le string, dans l'opération, est transformé en motif. Donc,
						# puisque cette durée est placée sur la première note, elle
						# se retrouve comme @duration du motif.
			].each do |d|
				suite, markin, markout, expected = d
				suite = previous_suite if suite.nil?
				it ":post_first_and_last_note sur «#{suite}» avec «#{markin}» et «#{markout}»" do
					res = LINote::post_first_and_last_note(suite, markin, markout)
					res.class.					should == Array
					res.first.class.		should == LINote
					LINote.implode(res).should == expected
				end
				previous_suite = suite
			end

			# :post_first_note
			it "doit répondre à :post_first_note" do
			  LINote.should respond_to :post_first_note
			end
			it ":post_first_note doit pouvoir recevoir un string" do
			  expect{LINote::post_first_note("a b c", '\)')}.not_to raise_error
			end
			it ":post_first_note doit pouvoir recevoir une liste de LINotes" do
				ary_ln = [LINote::new("a"), LINote::new("b")]
			  expect{LINote::post_first_note(ary_ln, '\)')}.not_to raise_error
			end
			it ":post_first_note doit lever une erreur si le signe est inconnu" do
				ary_ln = [LINote::new("a"), LINote::new("b")]
			  expect{LINote::post_first_note(ary_ln, '++')}.to raise_error
			end
			it ":post_first_note doit retourner une liste de LINotes" do
			  res = LINote::post_first_note("a b c", '\)')
				res.class.should == Array
				res.first.class.should == LINote
			end
			it ":post_first_note doit ajouter un signe à un post existant" do
			  ary = LINote::post_first_note("a b c", '\(')
				ary.first.to_llp.should == 'a\('
				res = LINote::post_first_note( ary, '\<' )
				res.class.should == Array
				res.first.class.should == LINote
				res.first.to_llp.should == 'a\(\<'
			end
			it ":post_first_note ne doit pas poser le signe sur un silence" do
				sig = '\('
			  res = LINote::post_first_note("r r r a b c", sig)
				res.first.post.should_not == sig
				res[3].to_llp.should == "a#{sig}"
			end

			# :post_last_note
			it "doit répondre à :post_last_note" do
			  LINote.should respond_to :post_last_note
			end
			it ":post_last_note doit pouvoir recevoir un string" do
			  expect{LINote::post_last_note("a b c", '\)')}.not_to raise_error
			end
			it ":post_last_note doit lever une erreur si le signe est inconnu" do
			  expect{LINote::post_last_note("a b c", '+')}.to raise_error
			end
			it ":post_last_note doit pouvoir recevoir une liste de LINotes" do
				ary_ln = [LINote::new("a"), LINote::new("b")]
			  expect{LINote::post_last_note(ary_ln, '\)')}.not_to raise_error
			end
			it ":post_last_note doit retourner une liste de LINotes" do
			  res = LINote::post_last_note("a b c", '\)')
				res.class.should == Array
				res.first.class.should == LINote
			end
			it ":post_last_note doit poser le post de la dernière note" do
			  res = LINote::post_last_note("a b c", '\)')
				res.last.to_llp.should == 'c\)'
			end
			it ":post_last_note doit ajouter au post existant" do
			  ary = LINote::post_last_note("a b c", '\)')
				ary.last.to_llp.should == 'c\)'
				res = LINote::post_last_note(ary, '\!')
				res.last.to_llp.should == 'c\)\!'
			end
			it ":post_last_note ne doit pas mettre le signe sur un silence" do
			  res = LINote::post_last_note("a b c r", '\)')
				res[2].to_llp.should == 'c\)'
			end
		end

		it "doit répondre à :up" do
		  LINote.should respond_to :up
		end
		it ":up ne doit pas toucher le motif initial" do
			iv_set(SCORE, :key => "E")
		  motif = Motif::new "e f# sol# la si do# re# mi"
			explosion = motif.explode
			LINote::up(explosion, 1)
			LINote::implode(explosion).should == "e fis gis a b cis dis e"
		end
		it ":up doit monter toutes les LINotes de la liste" do
			iv_set(SCORE, :key => "E")
		  motif = Motif::new "e f# sol# la si do# re# mi"
			explosion = motif.explode
			res = LINote::up(explosion, 1)
			LINote::implode(res).should == "fis gis a b cis dis e fis"
			res = LINote::up(explosion, 2)
			LINote::implode(res).should == "gis a b cis dis e fis gis"
		end
		it "doit répondre à :down" do
		  LINote.should respond_to :down
		end
		it ":down doit baisser toutes les LINotes de la liste" do
			iv_set(SCORE, :key => "E")
		  motif = Motif::new "e f# sol# la si do# re# mi"
			explosion = motif.explode
			res = LINote::down(explosion, 1)
			LINote::implode(res).should == "dis e fis gis a b cis dis"
			res = LINote::down(explosion, 2)
			LINote::implode(res).should == "cis dis e fis gis a b cis"
		end
		
		it "doit répondre à :note_str_in_context" do
		  pending "OBSOLÈTE"
		end
	end # /méthodes de classe

	# -------------------------------------------------------------------
	# 	Instances
	# -------------------------------------------------------------------
	describe "<linote>" do
	  before(:each) do
	    @ln = LINote::new "c"
	  end

		# Instanciation
		it "L'instanciation doit définir les valeurs qui font défaut" do
		  ln = LINote::new "c"
			ln.duration.should be_nil
			ln.delta.should == 0
		end
		
		# :set_octave
		it "doit répondre à :set_octave" do
		  @ln.should respond_to :set_octave
		end
		it ":set_octave doit modifier @octave" do
		  ln = LINote::new "c", :octave => 0
			ln.octave.should == 0
			ln.set_octave 2
			ln.octave.should == 2
		end
		it ":set_octave donne la bonne valeur quand delta" do
		  ln = LINote::new "c", :delta => -1, :octave => 2
			ln.octave.should == 2
			ln.delta.should == -1
			ln.set_octave 6
			ln.octave.should == 6
			ln.delta.should == -1
		end
		
		# :set_delta
		it "doit répondre à :set_delta" do
		  @ln.should respond_to :set_delta
		end
		it ":set_delta doit définir le delta" do
		  ln = LINote::new "c", :delta => 0
			ln.delta.should == 0
			ln.set_delta 2
			ln.delta.should == 2
		end
		# :mark_delta
		it "doit répondre à :mark_delta" do
		  @ln.should respond_to :mark_delta
		end
		it ":mark_delta doit renvoyer la bonne valeur en fonction du delta" do
		  ln = LINote::new "c"
			ln.mark_delta.should == ""
			ln.set :delta => 2
			ln.mark_delta.should == "''"
			ln.set :delta => -2
			ln.mark_delta.should == ",,"
		end
		# :abs / :to_midi
		it "doit répondre à :abs" do
		  ln = LINote::new "ces'"
			ln.should respond_to :abs
			ln.should respond_to :to_midi
		end
		[
			["c", 		4, 		60],
			["a", 		4, 		69],
			["a", 		0, 		21],
			["c", 		8, 		108],
			["ces", 	4, 		59],
			["bisis", 4, 		73]
		].each do |d|
			notes, octave, expected = d
			# it ":abs doit renvoyer #{expected} pour #{notes}:#{octave}" do
			it "SEULEMENT CE TEST-LÀ" do
				ln = LINote::new notes, :octave => octave
				ln.abs.should == expected
		  end
		end

		# ---- Méthodes pour la dynamique de la note -----
		describe "Dynamique" do
			def dynaln 
				iv_get(@ln, :dyna)
			end
			before(:each) do
			  @ln = LINote::new "c"
			end
			# :dyna
			it "doit posséder la propriété :dyna" do
			  @ln.should respond_to :dyna
				# Pour le reste, elle sera testée avec les autres méthodes
				# ci-dessous
			end
			it "doit répondre à :set_dyna" do
			  @ln.should respond_to :set_dyna
			end
			it ":set_dyna doit modifier la propriété @dyna" do
				dynaln.should be_nil
			  @ln.set_dyna :crescendo => true
				dynaln.should == {:crescendo => true, :start_intensite => nil,
					:end_intensite => nil, :start => true, :end => false }
					# @note: bien que :start => true ne soit pas précisé, le
					# fait de mettre :crescendo à true (ou false pour decrescendo)
					# met automatiquement :start à true
				@ln.set_dyna :start_intensite => 'ppp'
				dynaln.should == {:crescendo => true, :start_intensite => 'ppp',
					:end_intensite => nil, :start => true, :end => false}
				@ln.set_dyna nil
				dynaln.should == nil
				@ln.set_dyna :decrescendo => true, :end_intensite => 'p'
				dynaln.should == {:crescendo => false, :start_intensite => nil,
					:end_intensite => 'p', :start => false, :end => false}
				@ln.set_dyna :end => true
				dynaln.should == {:crescendo => false, :start_intensite => nil,
					:end_intensite => 'p', :start => false, :end => true}
			end
			it ":set_dyna doit retourner la LINote" do
			  res = @ln.set_dyna :crescendo => true
				res.class.should == LINote
				res.should == @ln
			end
			it "doit répondre à :start_crescendo" do
			  @ln.should respond_to :start_crescendo
			end
			it ":start_crescendo doit démarrer le crescendo" do
				@ln.start_crescendo
				dyna = dynaln
				dyna[:crescendo].should be_true
				dyna[:start].should be_true
				dyna[:end].should be_false
				dyna[:start_intensite].should be_nil
			end
			it "doit répondre à :crescendo_start?" do
			  @ln.should respond_to :crescendo_start?
			end
			it ":start_crescendo? doit retourner la bonne valeur" do
			  @ln.set(:dyna => nil)
				@ln.should_not be_crescendo_start
				@ln.start_crescendo
				@ln.should be_crescendo_start
			end
			it "doit répondre à :start_decrescendo" do
			  @ln.should respond_to :start_decrescendo
			end
			it ":start_decrescendo doit démarrer le decrescendo" do
				@ln.start_decrescendo
				dyna = dynaln
				dyna[:crescendo].should be_false
				dyna[:start].should be_true
				dyna[:end].should be_false
			end
			it "doit répondre à decrescendo_start?" do
			  @ln.should respond_to :decrescendo_start?
			end
			it ":decrescendo_start? doit retourner la bonne valeur" do
			  @ln.set(:dyna => nil)
				@ln.should_not be_decrescendo_start
				@ln.start_decrescendo
				@ln.should be_decrescendo_start
			end
			it "doit répondre à :end_crescendo" do
			  @ln.should respond_to :end_crescendo
			end
			it ":end_crescendo doit interrompre le crescendo" do
			  @ln.end_crescendo
				dynaln[:end].should be_true
			end
			it "doit répondre à :end_decrescendo" do
			  @ln.should respond_to :end_decrescendo
			end
			it ":end_decrescendo doit interrompre le decrescendo" do
				dynaln.should be_nil
			  @ln.end_decrescendo
				dynaln[:end].should be_true
			end
			it "doit répondre à :dynamique_start?" do
			  @ln.should respond_to :dynamique_start?
			end
			it ":dynamique_start? doit retourner la bonne valeur" do
			  @ln.set(:dyna => nil)
				@ln.should_not be_dynamique_start
				@ln.start_crescendo
				@ln.should be_dynamique_start
			  @ln.set(:dyna => nil)
				@ln.should_not be_dynamique_start
				@ln.start_decrescendo
				@ln.should be_dynamique_start
			end
			it "doit répondre à :dynamique_end?" do
			  @ln.should respond_to :dynamique_end?
			end
			it ":dynamique_end? doit retourner la bonne valeur" do
			  @ln.set(:dyna => nil)
				@ln.should_not be_dynamique_end
				@ln.end_crescendo
				@ln.should be_dynamique_end
			  @ln.set(:dyna => nil)
				@ln.should_not be_dynamique_end
				@ln.end_decrescendo
				@ln.should be_dynamique_end
			end
			it "doit répondre à :erase_dynamique" do
			  @ln.should respond_to :erase_dynamique
			end
			it ":erase_dynamique doit effacer la dynamique" do
			  @ln.set(:dyna => nil)
				iv_get(@ln, :dyna).should be_nil
				@ln.start_crescendo
				iv_get(@ln, :dyna).should_not be_nil
				@ln.erase_dynamique
				iv_get(@ln, :dyna).should be_nil
			end
			it "doit répondre à :start_intensite" do
			  @ln.should respond_to :start_intensite
			end
			it ":start_intensite doit définir l'intensité de départ" do
			  @ln.start_intensite 'ppp'
				dy = dynaln
				dy[:start_intensite].should == 'ppp'
			  @ln.start_intensite 'ff'
				dy = dynaln
				dy[:start_intensite].should == 'ff'
			end
			it "doit répondre à end_intensite" do
			  @ln.should respond_to :end_intensite
			end
			it ":end_intensite doit définir l'intensité de fin" do
			  @ln.end_intensite 'ppp'
				dy = dynaln
				dy[:end_intensite].should == 'ppp'
			  @ln.end_intensite 'ff'
				dy = dynaln
				dy[:end_intensite].should == 'ff'
			end
			it "doit répondre à :mark_dyna_start" do
			  @ln.should respond_to :mark_dyna_start
			end
			it ":mark_dyna_start doit retourner une chaine vide qd pas de dynamique" do
			  @ln.mark_dyna_start.should == ""
			end
			it ":mark_dyna_start doit retourner la marque de crescendo if any" do
			  @ln.start_crescendo
				@ln.mark_dyna_start.should == "\\<"
			end
			it ":mark_dyna_start doit retourner la marque de decrescendo if any" do
			  @ln.start_decrescendo
				@ln.mark_dyna_start.should == "\\>"
			end
			it ":mark_dyna_start doit retourner le signe de crescendo même si l'intensité est définie" do
			  @ln.start_crescendo
				@ln.start_intensite 'ppp'
				@ln.mark_dyna_start.should == "\\<"
			end
			it "doit répondre à :mark_dyna_end" do
			  @ln.should respond_to :mark_dyna_end
			end
			it ":mark_dyna_end doit retourner une chaine vide si pas de dynamique" do
			  @ln.mark_dyna_end.should == ""
			end
			it ":mark_dyna_end doit retourner la marque de fin de crescendo/decrescendo (if any)" do
			  @ln.end_crescendo
				@ln.mark_dyna_end.should == "\\!"
			end
			it ":mark_dyna_end doit retourne la marque de fin par une intensité (if any)" do
			  @ln.end_intensite ' \\pp'
				@ln.mark_dyna_end.should == " \\pp"
			end
			it "doit répondre à :mark_intensite_start" do
			  @ln.should respond_to :mark_intensite_start
			end
			it ":mark_intensite_start doit retourner une chaine vide si pas d'intensité de départ" do
			  @ln.mark_intensite_start.should == ""
			end
			it ":mark_intensite_start doit retourner l'intensité de départ (if any)" do
			  @ln.start_intensite 'fff'
				@ln.mark_intensite_start.should == "\\fff "
			end
		end # / fin de describe Dynamique
		
		describe "Slure et Legato" do
		  before(:each) do
		    @ln = LINote::new "c"
		  end
			it "doit répondre à :legato" do
			  @ln.should respond_to :legato
			end
			it "@legato doit être nil par défaut" do
			  @ln.legato.should be_nil
			end
			it "doit répondre à :checkif_legato_enable" do
			  @ln.should respond_to :checkif_legato_enable
				# est testée par la force des choses ci-dessous
			end
			it "doit répondre à :start_slure" do
			  @ln.should respond_to :start_slure
			end
			it ":start_slure doit régler la valeur de @legato" do
				@ln.legato.should be_nil
			  @ln.start_slure
				@ln.legato.should == LINote::BIT_START_SLURE
			end
			it ":start_slure doit lever une erreur s'il y a déjà une liaison quelconque" do
				iv_set(@ln, :legato => LINote::BIT_END_SLURE)
				err = detemp(Liby::ERRORS[:slure_unable_if_end_slure], :linote => @ln)
				expect{@ln.start_slure}.to raise_error(SystemExit, err)
				iv_set(@ln, :legato => LINote::BIT_START_LEGATO)
				expect{@ln.start_slure}.not_to raise_error
				iv_set(@ln, :legato => LINote::BIT_END_LEGATO)
				err = detemp(Liby::ERRORS[:slure_unable_if_end_legato], :linote => @ln)
				expect{@ln.start_slure}.to raise_error(SystemExit, err)
			end
			it "doit répondre à :end_slure" do
			  @ln.legato.should be_nil
				@ln.end_slure
				@ln.legato.should == LINote::BIT_END_SLURE
			end
			it ":end_slure doit lever une erreur s'il y a déjà une liaison quelconque" do
				iv_set(@ln, :legato => LINote::BIT_START_SLURE)
				err = detemp(Liby::ERRORS[:end_slure_unable_if_start_slure], :linote => @ln)
				expect{@ln.end_slure}.to raise_error(SystemExit, err)
				iv_set(@ln, :legato => LINote::BIT_START_LEGATO)
				err = detemp(Liby::ERRORS[:end_slure_unable_if_start_legato], :linote => @ln)
				expect{@ln.end_slure}.to raise_error(SystemExit, err)
				iv_set(@ln, :legato => LINote::BIT_END_LEGATO)
				expect{@ln.end_slure}.not_to raise_error
			end
			it "doit répondre à :erase_slure_end" do
			  @ln.should respond_to :erase_slure_end
			end
			it ":erase_slure_end doit effacer la fin de slure" do
			  @ln.set :legato => nil
				@ln.end_slure
				@ln.should be_slure_end
				@ln.erase_slure_end
				@ln.should_not be_slure_end
			end
			it "doit répondre à :start_legato" do
			  @ln.should respond_to :start_legato
			end
			it ":start_legato doit régler la valeur de @legato" do
			  @ln.start_legato
				@ln.legato.should == LINote::BIT_START_LEGATO
			end
			it ":start_legato doit lever une erreur s'il y a déjà une liaison quelconque" do
				iv_set(@ln, :legato => LINote::BIT_START_SLURE)
				err = detemp(Liby::ERRORS[:legato_unable_if_start_slure], :linote => @ln)
				expect{@ln.start_legato}.not_to raise_error
				iv_set(@ln, :legato => LINote::BIT_END_SLURE)
				err = detemp(Liby::ERRORS[:legato_unable_if_end_slure], :linote => @ln)
				expect{@ln.start_legato}.to raise_error(SystemExit, err)
				iv_set(@ln, :legato => LINote::BIT_END_LEGATO)
				err = detemp(Liby::ERRORS[:legato_unable_if_end_legato], :linote => @ln)
				expect{@ln.start_legato}.to raise_error(SystemExit, err)
			end
			it "doit répondre à :end_legato" do
				@ln.should respond_to :end_legato
			end
			it ":end_legato doit régler le legato" do
			  @ln.legato.should be_nil
				@ln.end_legato
				@ln.legato.should == LINote::BIT_END_LEGATO
			end
			it ":end_legato doit lever une erreur s'il y a déjà une liaison quelconque" do
				iv_set(@ln, :legato => LINote::BIT_START_SLURE)
				err = detemp(Liby::ERRORS[:end_legato_unable_if_start_slure], :linote => @ln)
				expect{@ln.end_legato}.to raise_error(SystemExit, err)
				iv_set(@ln, :legato => LINote::BIT_END_SLURE)
				expect{@ln.end_legato}.not_to raise_error
				iv_set(@ln, :legato => LINote::BIT_START_LEGATO)
				err = detemp(Liby::ERRORS[:end_legato_unable_if_start_legato], :linote => @ln)
				expect{@ln.end_legato}.to raise_error(SystemExit, err)
			end
			it "doit répondre à :erase_legato_end" do
			  @ln.should respond_to :erase_legato_end
			end
			it ":erase_legato_end doit effacer la fin de legato" do
			  @ln.set :legato => nil
				@ln.end_legato
				@ln.should be_legato_end
				@ln.erase_legato_end
				@ln.should_not be_legato_end
			end
			
			it "doit répondre à :mark_legato" do
			  @ln.should respond_to :mark_legato
			end
			[
				[nil, ""], 
				[LINote::BIT_START_SLURE, "("], 
				[LINote::BIT_END_SLURE, ")"], 
				[LINote::BIT_START_LEGATO, "\\("], 
				[LINote::BIT_END_LEGATO, "\\)"],
				[LINote::BIT_START_SLURE|LINote::BIT_START_LEGATO, "\\(("],
				[LINote::BIT_END_LEGATO|LINote::BIT_END_SLURE, ")\\)"]
			].each do |d|
				legato, expected = d
				it ":mark_legato doit renvoyer #{expected} si legato = #{legato}" do
					iv_set(@ln, :legato => legato)
					@ln.mark_legato.should == expected
			  end
			end
			it "doit répondre à :slure_start?" do
			  @ln.should respond_to :slure_start?
			end
			it ":slure_start? doit retourner la bonne valeur" do
				iv_set(@ln, :legato => nil)
			  @ln.should_not be_slure_start
				iv_set(@ln, :legato => LINote::BIT_START_SLURE | LINote::BIT_START_LEGATO)
				@ln.should be_slure_start
			end
			it "doit répondre à :legato_start?" do
			  @ln.should respond_to :legato_start?
			end
			it ":legato_start? doit retourner la bonne valeur" do
				iv_set(@ln, :legato => nil)
				@ln.should_not be_legato_start
			  iv_set(@ln, :legato => LINote::BIT_START_SLURE | LINote::BIT_START_LEGATO)
				@ln.should be_legato_start
			end
			it "doit répondre à :slure_end?" do
			  @ln.should respond_to :slure_end?
			end
			it ":slure_end? doit retourner la bonne valeur" do
				iv_set(@ln, :legato => nil)
				@ln.should_not be_slure_end
			  iv_set(@ln, :legato => LINote::BIT_END_SLURE | LINote::BIT_END_LEGATO)
				@ln.should be_slure_end
			end
			it "doit répondre à :legato_end?" do
			  @ln.should respond_to :legato_end?
			end
			it ":legato_end? doit retourner la bonne valeur" do
				iv_set(@ln, :legato => nil)
				@ln.should_not be_legato_end
			  iv_set(@ln, :legato => LINote::BIT_END_SLURE | LINote::BIT_END_LEGATO)
				@ln.should be_legato_end
			end
		end # / fin de describe Légato
		
		# :au_dessus_de? / above?
		it "doit répondre à :au_dessus_de? / :above?" do
		  ln = LINote::new "ces'"
			ln.should respond_to :au_dessus_de?
			ln.should respond_to :above?
		end
		# :plus_haute_que? / :higher_than
		it "doit répondre à :plus_haute_que? / :higher_than" do
		  ln = LINote::new "ceses,"
			ln.should respond_to :plus_haute_que?
			ln.should respond_to :higher_than?
		end
		[
			["c", "c", false, false],
			["c", "d", false, false],
			["ces", "bis", true, false],
			["c", "bisis", true, false],
			["eis", "fes", false, true],
			["e", "feses", false, true],
			["c", "fis", false, false],
			["c", "a", true, false],
			["c", "g", true, false],
			["g", "c", false, true],
			["a", "c", false, true],
			["g", "c", false, true],
			["c", "ges", true, false],
			["c", "fis", false, false],
			["c'", "fis", false, true],
			["fis", "c", true, true],
			["fis", "c'", false, false]
		].each do |d|
			notes_ln1, notes_ln2, au_dessus, plus_haut = d
			texte = "#{notes_ln1}:au_dessus_de?(#{notes_ln2}) doit => #{au_dessus} et "
			texte << "#{notes_ln1}:higher_than?(#{notes_ln2}) doit => #{plus_haut}"
			it texte do
				ln1 = LINote::new notes_ln1
				ln2 = LINote::new notes_ln2
				ln1.au_dessus_de?(ln2).should === au_dessus
				res = ln1.higher_than?(ln2)
				if res != plus_haut
					puts "\nERREUR avec #{notes_ln1}:higher_than?(#{notes_ln2})"
					puts "Réponse attendue : #{plus_haut}"
					puts "Réponse reçue    : #{res}"
					puts "Valeur absolue de #{notes_ln1} : #{ln1.abs}"
					puts "Valeur absolue de #{notes_ln2} : #{ln2.abs}"
					puts "Détail linote 1 : #{ln1.inspect}"
					puts "Détail linote 2 : #{ln2.inspect}"
					res.should 	=== plus_haut
				end
			end
		end

		# :to_s
		# ATTENTION : ça n'est plus un alias de :to_llp
		it "doit répondre à :to_s" do
		  @ln.should respond_to :to_s
		end
		it ":to_s doit retourner la bonne valeur" do
		  ln = LINote::new "c"
			ln.to_s.should == "\\relative c' { c }"
			ln = LINote::new :note => "c#", :octave => 1, :duree => "8", :jeu => "^"
			ln.to_s.should == "\\relative c,, { cis8-^ }"
		end

		# :with_alter
		it "doit répondre à :with_alter" do
		  @ln.should respond_to :with_alter
		end
		it ":with_alter doit renvoyer la bonne valeur" do
		  ln = LINote::new "eeses"
			ln.note.should == "e"
			ln.alter.should == "eses"
			ln.with_alter.should == "eeses"
			ln = LINote::new "c"
			ln.note.should == "c"
			ln.alter.should be_nil
			ln.with_alter.should == "c"
		end
		
		# :to_llp
		it "doit répondre à :to_llp)" do
		  @ln.should respond_to :to_s
		end
		dur = "duration"
		dup = "duree_post"
		olp = "delta/N"
		dyn = "dynamique"
		data_test = <<-DEFH
			note			pre		post	#{dur} #{dup} #{olp} alter jeu finger #{dyn} res
		-------------------------------------------------------------------
			c					-			-			-			-				-			-			-			-			-			c
			c					-			(			4			-				1			es		-			-			-			ces'4(
			c					<     -			8			-				-2		isis	^		-			\\!		<cisis,,8-^\\!
		-------------------------------------------------------------------
		DEFH
		# @TODO: trouver une autre méthode, car celle-ci n'est vraiment
		# pas bonne. Par exemple, dans un traitement réel, la durée de la
		# dernière note ne serait pas appliquée à la note courante mais à
		# la fin de l'accord. Le motif `<cisis,,8' est donc faux.
		data_test = data_test.to_array
		data_test.each do |dlinote|
			res = dlinote.delete(:res)
			dynamique = dlinote.delete(:dynamique)
			dyna = 	unless dynamique.nil?
				case dynamique
				when "\\!" then {:end => true}
				when "\\<" then {:start => true, :crescendo => true}
				when "\\>" then {:start => true, :crescendo => false}
				else nil
				end
			else nil end
			dlinote[:dyna] = dyna
			
			data_displayed = {}
			dlinote.each do |k, v| 
				next if v.nil? 
				data_displayed[k] = v 
			end
			it ":to_s avec {#{data_displayed.inspect}} doit rendre : '#{res}'" do
				linote = LINote::new dlinote
				linote.to_llp.should == res
			end
		end
		
		# :to_hash
		it "doit répondre à :to_hash" do
		  @ln.should respond_to :to_hash
		end
		it ":to_hash doit renvoyer la bonne valeur" do
			hash = {:note => "c", :duration => 4, :delta => 2,
							:alter => "es" }
		  ln = LINote::new hash
		 	ln_to_hash = ln.to_hash
			hash.each { |prop, val| ln_to_hash[prop].should == val }
			ln = LINote::new "aisis''8"
			hash_ln = ln.to_hash
			hash_ln[:note].should 		== "a"
			hash_ln[:duration].should == "8"
			hash_ln[:alter].should 		== "isis"
			hash_ln[:delta].should 		== 2
			hash_ln[:octave].should 	== nil
		end
		
		# :clone
		it "doit répondre à :clone" do
		  @ln.should respond_to :clone
		end
		it ":clone doit faire un clone de la LINote" do
		  ln1 = LINote::new "c", :alter => "is", :octave => 5
			ln2 = ln1.clone
			ln2.octave.should == 5
			ln1.set :octave => 1
			ln1.octave.should == 1
			ln2.octave.should == 5
			ln2.set :alter => ""
			ln1.with_alter.should == "cis"
			ln2.with_alter.should == "c"
		end

		# :as_note
		it "doit répondre à :as_note" do
		  @ln.should respond_to :as_note
		end
		it ":as_note doit retourner la linote en instance de Note" do
		  ln = LINote::new :note => "c", :alter => "es", :octave => 4
			note = ln.as_note
			note.class.should == Note
			note.it.should == "c"
		end
		# :to_llp
		it "doit répondre à :to_llp" do
		  @ln.should respond_to :to_llp
			# @note: la méthode est vérifiée ci-dessus, avec LINote::explode
			# @note: et elle est encore testée plus loin avec son alias
			# :to_s
		end
		
		# :set
		it "doit répondre à :set" do
		  @ln.should respond_to :set
		end
		it ":set doit permettre de définir les valeurs" do
			iv_get(@ln, :duration).should be_nil
		  @ln.set(:duration => 16)
			iv_get(@ln, :duration).should == "16"
			iv_get(@ln, :finger).should be_nil
			@ln.set(:finger => "5")
			iv_get(@ln, :finger).should == "5"
		end
		
		# :get
		it "doit répondre à :get" do
		  @ln.should respond_to :get
		end
		it ":get doit renvoyer les bonnes valeurs" do
		  ln = LINote::new 'cis', :octave => 2, :duration => "4~"
			ln.get(:note).should == "c"
			ln.get(:alter).should == "is"
			ln.get(:octave).should == 2
			ln.get(:duration).should == "4~"
		end
				
		# :natural_octave_after
		it "doit répondre à :natural_octave_after" do
		  @ln.should respond_to :natural_octave_after
		end
		it ":natural_octave_after doit lever une erreur si le 1er param n'est pas une linote" do
			err = detemp(Liby::ERRORS[:param_method_linote_should_be_linote],
									:ln => @ln, :method => "natural_octave_after")
		  expect{@ln.natural_octave_after("a")}.to raise_error(SystemExit, err)
		end
		ary = <<-DEFA
			note1 o1/N		note2		expected/N
		---------------------------------------
			c			1				c				1
			c			2				c				2
			c			2				a				1
			c			5				fis			5
			fis		5				c				5
			fis		5				cisis		5
			g			5				c				6
			g			5				cisis		6
		---------------------------------------
		DEFA
		ary.to_array.each do |d|
			ln1 = LINote::new( d[:note1], :octave => d[:o1])
			ln2 = LINote::new( d[:note2], :octave => 0)
			octave_expected = d[:expected]
			message = "#{ln2.note}-#{ln2.octave}.natural_octave_after" \
								<< "(#{ln1.note}-#{ln1.octave}) doit retourner " \
								<< "#{octave_expected} comme octave naturel"
			it message do
			  ln2.natural_octave_after(ln1).should == octave_expected
			end
		end
		
		# :as_next_of
		it "doit répondre à :as_next_of" do
		  @ln.should respond_to :as_next_of
		end
		it ":as_next_of doit lever une erreur si le paramètre n'est pas une linote" do
			err = detemp(Liby::ERRORS[:param_method_linote_should_be_linote], 
										:ln => @ln, :method => "as_next_of")
		  expect{@ln.as_next_of('')}.to raise_error(SystemExit, err)
		end
		ary = <<-DEFA
				note1	o1/N		note2	o2/N	delta/N
			----------------------------------
					a			-				a		-				-
					a			1				a		0				-1
					a			1				c 	0				-2
					a			1				c		1				-1
					a			1				c		2				-
					f			1				c		1				-
					f			1				c		2				1
					f			2				c		1				-1
					g			2				c		3				-
					g			2				c		5				2
			----------------------------------
		DEFA
		ary.to_array.each do |d|
			delta_expected = d[:delta] || 0
			ln1 = LINote::new(d[:note1], :octave => d[:o1])
			ln2 = LINote::new(d[:note2], :octave => d[:o2])
			texte = "#{d[:note2]}-#{d[:o2]}:as_next_of" \
							<< "(#{d[:note1]}-#{d[:o1]})" \
							<< " doit mettre le delta à #{delta_expected}"
			it texte do
				ln2.as_next_of ln1 # @TODO: ici, il faut certainement indiquer que c'est le delta à modifier
				ln2.delta.should == delta_expected
		  end
		end
		# :rest?
		it "doit répondre à :rest?" do
		  @ln.should respond_to :rest?
		end
		it ":rest? doit renvoyer la bonne valeur" do
			@ln.should_not be_rest
			iv_set(@ln, :note => 'r')
			@ln.should be_rest
		end
		
		# :in_accord?
		it "doit répondre à :in_accord?" do
		  @ln.should respond_to :in_accord?
		end
		it ":in_accord? doit renvoyer la bonne valeur" do
		  motif = Motif::new "a <b c d> e f"
			exp = motif.exploded
			exp.first.should_not be_in_accord
			exp[1].should be_in_accord
			exp[2].should be_in_accord
			exp[3].should be_in_accord
			exp[4].should_not be_in_accord
			exp[5].should_not be_in_accord
		end
		# :end_accord?
		it "doit répondre à :end_accord?" do
		  @ln.should respond_to :end_accord?
		end
		it ":end_accord? doit retourner true si c'est la dernière d'un accord" do
		  motif = Motif::new "<a b c>"
			motif.exploded.last.should be_end_accord
		end
		it ":end_accord? doit retourner false si ce n'est pas la dernière d'un accord" do
		  motif = Motif::new "<a b c> r c"
			motif.exploded.last.should_not be_end_accord
		end
		# :start_accord?
		it "doit répondre à :start_accord?" do
		  @ln.should respond_to :start_accord?
		end
		it ":start_accord? doit retourner true si c'est la première note d'un accord" do
		  motif = Motif::new "<a b c>"
			motif.exploded.first.should be_start_accord
		end
		it ":start_accord? doit retourner false si ce n'est pas la 1ère d'un accord" do
		  motif = Motif::new "a b c"
			motif.exploded.first.should_not be_start_accord
		end
		
		# :diese?
		it "doit répondre à :diese?" do
		  @ln.should respond_to :diese?
		end
		it ":diese doit retourner la bonne valeur" do
		  iv_set(@ln, :alter => nil)
			@ln.diese?.should be_false
		  iv_set(@ln, :alter => "es")
			@ln.diese?.should be_false
		  iv_set(@ln, :alter => "isis")
			@ln.diese?.should be_true
		  iv_set(@ln, :alter => "is")
			@ln.diese?.should be_true
		end
		# :bemol?
		it "doit répondre à :bemol?" do
		  @ln.should respond_to :bemol?
		end
		it ":bemol? doit retourner la bonne valeur" do
		  iv_set(@ln, :alter => nil)
			@ln.bemol?.should be_false
		  iv_set(@ln, :alter => "es")
			@ln.bemol?.should be_true
		  iv_set(@ln, :alter => "isis")
			@ln.bemol?.should be_false
		  iv_set(@ln, :alter => "eses")
			@ln.bemol?.should be_true
		end
		
		# :after?
		it "doit répondre à :after?" do
		  @ln.should respond_to :after?
		end
	  [
			["c", "c", true],
			["c", "d", true],
			["cis", "c", true], 		# cas spécial
			["ces", "bis", true]		# cas spécial
		].each do |d|
			suite1, suite2, expected = d
			it "#{suite1} :after? #{suite2} doit renvoyer #{expected}" do
				ln1 = LINote::new suite1
				ln2 = LINote::new suite2
				ln2.after?( ln1 ).should === expected
			end
		end
		
		# :index
		it "doit répondre à :index" do
		  @ln.should respond_to :index
		end
		it ":index doit renvoyer l'index dans la gamme chromatique" do
		  ln = LINote::new "c"
			ln.index.should == 0
			ln = LINote::new "d'"
			ln.index.should == 2
			ln = LINote::new "b,,4"
			ln.index.should == 11
			ln = LINote::new 'r'
			ln.index.should === nil
		end
		
		# :index_diat
		it "doit répondre à :index_diat" do
		  @ln.should respond_to :index_diat
		end
		[
			["c", 0], ["d", 1], ["e", 2], ["f", 3], ["g", 4], ["a", 5], ["b", 6]
		].each do |d|
			basenote, expected = d
			["", "es", "eses", "is", "isis"].each do |alter|
				note = "#{basenote}#{alter}"
				it ":index_diat pour #{note} doit renvoyer #{expected}" do
					ln = LINote::new note
					ln.index_diat.should == expected
				end
		  end
		end
		
		describe "Méthodes pour la durée" do
			
			# :mark_duration
			it "doit répondre à :mark_duration" do
			  @ln.should respond_to :mark_duration
			end
			it ":mark_duration doit retourner la bonne valeur (cas simples)" do
			  ln = LINote::new "c", :duree => "4"
				ln.mark_duration.should == "4"
				ln.set :duration => nil
				ln.mark_duration.should == ""
				ln.set :duration => '~'
				ln.mark_duration.should == "~"
				ln.set :duration => "2."
				ln.mark_duration.should == "2."
			end
			it ":mark_duration doit retourner la bonne valeur (cas complexe)" do
			  # Un cas complexe, c'est un cas où la LINote est la première
				# d'un motif, mais qu'elle fait partie d'un accord. Dans ce 
				# cas-là, la durée doit être appliquée à la dernière note de
				# l'accord.
				# Ce cas est géré dans les motifs
			end
			
			# :duration
			it "doit répondre à :duration" do
			  @ln.should respond_to :duration
			end
			it ":duration doit renvoyer la bonne valeur" do
			  motif = Motif::new "<a c e>8."
				ary_linotes = motif.explode
				ln = ary_linotes.last
				ln.duree_chord.should == "8."
			end
			it ":duration doit retourner la durée d'une note d'accord" do
			  motif = Motif::new "<a c e>8."
				ary_linotes = motif.explode
				prem_ln = ary_linotes[1]
				prem_ln.duration.should be_nil
				prem_ln.duration(true).should == "8."
			end

			# :duree_points_to_float
			it "doit répondre à :duree_points_to_float" do
			  @ln.should respond_to :duree_points_to_float
			end
			# :duree_absolue
			it "doit répondre à duree_absolue" do
			  @ln.should respond_to :duree_absolue
			end
			{
				"1/"  => 4.0, "2/" => 2.0, "4/" => 1.0, "8/" => 0.5, "16/" => 0.25,
				"32/" => 0.125,
				"1/." => 6.0, "2/." => 3.0, "4/." => 1.5, "8/." => 0.75, "16/." => 0.375,
				"1/.." => 7.0, "2/.." => 3.5, "4/.." => 1.75
			}.each do |dduree, expected|
				nombre, points = dduree.split('/')
				duree = "#{nombre}#{points}"
				it "La durée absolue pour une durée LilyPond de '#{duree}' doit être #{expected}" do
				  ln = LINote::new "c", :duree => duree
					ln.duree_absolue.should == expected
				end
				it "La durée absolue doit pouvoir recevoir une durée absolue en argument" do
				  ln = LINote::new "c~"
					ln.duree_absolue(expected).should == expected
				end
				it ":duree_points_to_float(#{nombre}, '#{points}') doit retourner #{expected}" do
					ln = LINote::new "c"
					ln.duree_points_to_float(nombre, points).should == expected
				end
			end
			it "La durée absolue doit utiliser la valeur par défaut si pas de durée" do
			  ln = LINote::new "c"
				ln.duration.should be_nil
				ln.duree_absolue("4").should == 1.0
			end
			it "La durée absolue doit utiliser la valeur par défaut si la durée est ~" do
			  ln = LINote::new "c~"
				ln.duration.should == "~"
				ln.duree_absolue("2").should == 2.0
			end
		end # / fin describe méthodes pour la durée
		
		# -------------------------------------------------------------------
		# 	Méthode de changement de hauteur
		# -------------------------------------------------------------------
		describe "Changement de hauteur" do
		  it "doit répondre à :up" do
		    @ln.should respond_to :up
		  end
			it ":up doit monter la note dans la tonalité de do" do
				iv_set(SCORE, :key => "C")
			  ln = LINote::new "c", :octave => 0
				res = ln.up(1)
				res.with_alter.should == "d"
				ln.up(2).with_alter.should == "e"
				ln.up(3).with_alter.should == "f"
				ln.up(4).with_alter.should == "g"
				ln.up(5).with_alter.should == "a"
				ln.up(6).with_alter.should == "b"
				res = ln.up(7)
				res.with_alter.should == "c"
				res.octave.should == 1
				ln.up(8).with_alter.should == "d"
				ln.up(9).with_alter.should == "e"
				ln.up(10).with_alter.should == "f"
				ln.up(11).with_alter.should == "g"
				ln.up(12).with_alter.should == "a"
				ln.up(13).with_alter.should == "b"
				res = ln.up(14)
				res.with_alter.should == "c"
				res.octave.should == 2
			end
			it "doit répondre à :down" do
			  @ln.should respond_to :down
			end
			it ":down doit descendre la note dans la tonalité choisie" do
			  iv_set(SCORE, :key => "C")
				ln = LINote::new "d", :octave => 3
				ln.down(1).with_alter.should == "c"
			  iv_set(SCORE, :key => "D")
				ln.down(1).with_alter.should == "cis"
				ln.down(2).with_alter.should == "b"
				ln.down(3).with_alter.should == "a"
				ln.down(4).with_alter.should == "g"
				ln.down(5).with_alter.should == "fis"
				ln.down(6).with_alter.should == "e"
				res = ln.down(7)
				res.with_alter.should == "d"
				res.octave.should == 2
			end
		end # / Describe changement de hauteur
		
		# :str_in_context
		it "doit répondre à :str_in_context" do
		  @ln.should respond_to :str_in_context
		end
		it ":str_in_context doit renvoyer la bonne valeur" do
			pending "Méthode à ré-implémenter complètement"
		end
		it "doit répondre à :moins" do
		  @ln.should respond_to :moins
		end
		it ":moins doit renvoyer la bonne valeur" do
			iv_set(@ln, :note => "c")
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