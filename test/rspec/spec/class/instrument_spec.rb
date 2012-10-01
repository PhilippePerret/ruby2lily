# 
# Tests de la classe Instrument
# 
require 'spec_helper'
require 'instrument'

describe Instrument do
	before(:all) do
	  SCORE = Score::new unless defined? SCORE
		iv_set(SCORE, :key => nil)
		iv_set(SCORE, :bars => nil)
	end
	# -------------------------------------------------------------------
	# Tests de la classe
	# -------------------------------------------------------------------
  describe "La classe" do
    it "doit répondre à :new" do
      Instrument.should respond_to :new
    end
		it ":new doit retourner un objet de type Instrument" do
		  Instrument.new.class.should == Instrument
		end
		it "doit répondre à :code_show_bar_numbers" do
		  pending "à implémenter"
		end
		it ":code_show_bar_numbers doit retourner le bon code" do
		  pending "à implémenter"
		end
  end # /la classe

	# -------------------------------------------------------------------
	# Tests de l'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @instru = Instrument::new( {} )
	  end
	
		describe "Explosion (explode)" do

			# :explode
			it "doit répondre à :explode" do
			  @instru.should respond_to :explode
			end
			it ":explode doit retourner un array de toutes les LINotes" do
				voix = Voice::new
				voix << "a b c d"
				voix << "<c e g>8"
			  res = voix.explode
				res.class.should == Array
				res.count.should == 7
				res.each do |ln|
					ln.class.should == LINote
				end
				ln = res[0]
				ln.duration.should be_nil
				ln.note.should == "a"
				ln.octave.should == 4
				
				ln = res[5]
				ln.note.should == "e"
				ln.octave.should == 4
				ln.duration.should be_nil
				ln.duree_chord == "8"
				
				ln = res[6]
				ln.note.should == "g"
				ln.octave.should == 4
				ln.duration.should == "8"
				ln.duree_chord == "8"
				
			end
			
			it ":explode doit définir la durée de la première linote si non définie" do
				voix = Voice::new
				voix << "a4 b c d"
				voix << "<c e g>8"
				motif1 = iv_get(voix, :motifs).first
				linote1 = motif1.first_note
				linote1.duration.should be_nil
				motif1.duration.should == "4"
				voix.explode.first.duration.should == "4"
			end
		end
		
		# -------------------------------------------------------------------
		# 	Sélection de mesures ( + barres spéciales )
		# -------------------------------------------------------------------
		describe "Sélection de mesures" do
			before(:each) do
			  @voix = Voice::new
			end
			it "doit répondre à :mesures et :measures" do
			  @instru.should respond_to :mesures
			  @instru.should respond_to :measures
				@instru.should respond_to :measure
				@instru.should respond_to :mesure
			end
			it "Motif unique doit renvoyer les bonnes notes" do
				@voix << "a4 b c d eis4-^ f g a"
				res = @voix.mesures(2, 2)
				res.to_s.should == "eis4-^ f g a"
			end
			it ":mesure(s) doit accepter un seul paramètre" do
				@voix << "a4 b c d eis4-^ f g a"
			  expect{@voix.mesure(1)}.not_to raise_error
			end
			it ":mesure(s) avec un seul paramètre doit retourner la mesure seule" do
				@voix << "a4 b c d eis4-^ f g a"
			  @voix.mesure(1).to_s.should == "a4 b c d"
			  @voix.mesure(2).to_s.should == "eis4-^ f g a"
			end
			it "doit renvoyer les bonnes notes avec deux motifs" do
				@voix << Motif::new("c c c c d d d d")
				@voix << Motif::new("e e e e f f f f")
				res = @voix.mesures(2, 3)
				res.to_s.should == "d d d d e e e e"
			end
			it "doit pouvoir traiter seulement des silences" do
			  @voix << Motif::new("r r r r r r r r r r r r r r r r r")
				res = @voix.mesures(2,3)
				res.to_s.should == "r r r r r r r r"
			end
			it "doit insérer la barre de mesure spéciale si nécessaire" do
				SCORE::bars 3 => '||'
				@voix << Motif::new("c c c c d d d d")
				@voix << Motif::new("e e e e f f f f")
				res = @voix.mesures(2, 3)
				iv_set(SCORE, :bars => nil)
				res.to_s.should == "d d d d \\bar \"||\" e e e e"
			end
			it "doit renvoyer les bonnes notes avec des liaisons de durée (~)" do
			  @voix << Motif::new("c c~ c c~ c b b b")
				@voix.mesure(1).should == "c c~ c c"
			end
			it "doit renvoyer les bonnes notes avec un motif sans durée commençant par un tilde" do
			  @voix << Motif::new("c~ c c c b b b b")
				@voix.mesure(1).should == "c~ c c c"
			end
			it "une liaison de durée à la fin (~) doit être supprimée" do
			  @voix << Motif::new("c c c c b b b b~ b c c c", :duration => "4")
				@voix.mesure(2).should_not == "b b b b~"
				@voix.mesure(2).should == "b b b b"
			end
			it "doit renvoyer jusqu'à la dernière si last = -1" do
				@voix << Motif::new("c c c c d d d d")
				@voix << Motif::new("e e e e f f f f")
				res = @voix.mesures(1, -1)
				res.to_s.should == "c c c c d d d d e e e e f f f f"
			end
			it "doit tenir compte des accords" do
			  @voix << Motif::new("<c e g>1 <a c e>2")
				@voix << Motif::new("<e g b>2 <b d fis>1")
				@voix.mesures(1).to_s.should == "<c e g>1"
				@voix.mesures(2).to_s.should == "<a c e>2 <e g b>2"
				@voix.mesures(3).to_s.should == "<b d fis>1"
			end
			it "doit bien gérer les accords" do
			  @voix << Motif::new("<c e g> <d fis la> <e sol si>", :duration => "1")
				@voix.mesures(2,3).should == "<d fis a> <e g b>"
			end
			it "doit tenir compte d'une durée définie avant" do
			  @voix << Motif::new("a a a a b1 c d e f")
				@voix.mesure(1).to_s.should == "a a a a"
				@voix.mesure(2).to_s.should == "b1"
				@voix.mesure(4).to_s.should == "d"
				@voix.mesure(5,6).to_s.should == "e f"
			end
			it "ne doit pas produire d'erreur si last est trop grand" do
			  @voix << Motif::new("a a a a")
				expect{@voix.mesure(10)}.not_to raise_error
			end
			it "doit mettre des silences si last est trop grand" do
			  @voix << Motif::new("a a a a")
				@voix.mesure(2).should == "r1"
			end
			it "doit ajouter juste ce qu'il faut de silence" do
			  pending "à implémenter"
				@voix << Motif::new("a a a a a a")
				@voix.msure(2).should == "a a r2"
			end
			it "doit conserver un slure compris dans les mesures" do
			  @voix << Motif::new("a a a a b b( b b c c) c c d d d d")
				@voix.mesures(2,3).should == "b b( b b c c) c c"
			end
			it "doit conserver un legato compris dans les mesures" do
			  @voix << Motif::new( "a a a a b b b\\( b c\\) c c c d d d d")
				@voix.mesures(2,3).should == "b b b\\( b c\\) c c c"
			end
			it "doit conserver un crescendo compris dans les mesures" do
			  @voix << Motif::new( "a a a a b b\\< b b c c\\! c c d d d d")
				@voix.mesures(2,3).should == "b b\\< b b c c\\! c c"
			end
			it "doit conserver une marque de dynamique comprise dans les mesures" do
			  @voix << Motif::new( "a a a a b b\\< b b c c\\! c c d d d d")
				@voix.mesures(2,3).should == "b b\\< b b c c\\! c c"
			end
			it "doit ajouter un début de dynamique qui commence avant" do
			  @voix << Motif::new("a\\< a a a b b b\\! b")
				@voix.mesure(2).should ==      "b\\< b b\\! b"
			end
			it "doit ajouter une fin de dynamique qui finirait après" do
			  @voix << Motif::new("a a a a b\\< b b b c c c c\\!")
				@voix.mesure(2).should ==   "b\\< b b b\\!"
			end
			it "doit ajouter un début de slure qui commence avant" do
			  @voix << Motif::new("a( a a a b b b) b")
				@voix.mesure(2).should == "b( b b) b"
			end
			it "doit ajouter une fin de slure qui finirait après" do
			  @voix << Motif::new("a a a a b( b b b c c c) c")
				@voix.mesure(2).should == "b( b b b)"
			end
			it "doit ajouter un début de legato qui commence avant" do
			  @voix << Motif::new("a\\( a a a b b b\\) b")
				@voix.mesure(2).should == "b\\( b b\\) b"
			end
			it "doit ajouter une fin de legato qui finirait après" do
			  @voix << Motif::new("a a a a b b\\( b b c c c c d d d\\) d")
				@voix.mesure(2, 3).should == "b b\\( b b c c c c\\)"
			end
			it "doit supprimer le slure s'il termine sur la première note" do
			  @voix << Motif::new("a( a a a b) b b b")
				@voix.mesure(2).should == "b b b b"
			end
			it "doit supprimer le legato s'il termine sur la première note" do
			  @voix << Motif::new("a a a a\\( b\\) b b b")
				@voix.mesure(2).should == "b b b b"
			end
			it "doit supprimer le slure s'il commence sur la dernière note" do
			  @voix << Motif::new( "a a a a b b b b( c c c) c" )
				@voix.mesure(2).should == "b b b b"
			end
			it "doit supprimer le slure des deux côtés si nécessaire" do
			  @voix << Motif::new( "a a a( a b) b b b( c c c) c" )
				@voix.mesure(2).should == "b b b b"
			end
			it "doit supprimer le legato s'il commence sur la dernière note" do
			  @voix << Motif::new( "a a a a b b b b\\( c c\\) c c" )
				@voix.mesure(2).should == "b b b b"
			end
			it "doit supprimer le legato des deux côtés si nécessaire" do
			  @voix << Motif::new( "a a\\( a a b\\) b b b\\( c c\\) c c" )
				@voix.mesure(2).should == "b b b b"
			end
			it "doit supprimer la dynamique si elle termine sur la première note" do
			  @voix << Motif::new( "a a\\> a a b\\! b b b c c c c" )
				@voix.mesure(2).should == "b b b b"
			end
			it "doit supprimer la dynamique si elle commence sur la dernière note" do
			  @voix << Motif::new( "a a a a b b b b\\< c c\\! c c" )
				@voix.mesure(2).should == "b b b b"
			end
			it "doit supprimer la dynamique des deux côtés si nécessaire" do
			  @voix << Motif::new( "a a\\< a a b\\! b b b\\> c c c\\!" )
				@voix.mesure(2).should == "b b b b"
			end
			it "doit ajouter toutes les marques manquantes (slure, legato, dynamique)" do
			  @voix << Motif::new("a\\( a( a\\< a b b)\\) b\\! b\\> c c c c\\( d d d\\! d\\)")
				@voix.mesures(2,3).should == "b\\((\\< b)\\) b\\! b\\> c c c c\\!"
			end
		end


		# -------------------------------------------------------------------
		# 	Méthodes de définition de la partition
		# -------------------------------------------------------------------
		describe "Définition de la partition" do
			before(:each) do
			  iv_set(@instru, :motifs => [])
			end
			# :add
		  it "doit répondre à la méthode :add" do
		    @instru.should respond_to :add
		  end
			it ":add doit accepter des notes en string" do
			  @instru.add "a b c"
			end
			it "doit répondre à :<<" do
			  @instru.should respond_to :<<
			end
			it ":<< doit ajouter les notes" do
			  @instru << "a b e"
				@instru.to_llp.should == "\\relative c' { a b e }"
			end
			
			# :add_as_string
			it "doit répondre à :add_as_string" do
			  @instru.should respond_to :add_as_string
			end
			it ":add_as_string doit ajouter les notes" do
				notes = "a b c"
				iv_set(@instru, :motifs => [])
			  @instru.add notes
				@instru.to_llp.should == "\\relative c' { a b c }"
				@instru.add "fb b##"
				@instru.to_llp.should == 
					"\\relative c' { a b c } \\relative c' { fes bisis }"
			end
			
			# :add_as_chord
			it "doit répondre à :add_as_chord" do
			  @instru.should respond_to :add_as_chord
			end
			it ":add_as_chord doit ajouter l'accord" do
				accord = Chord::new ["c", "eb", "g"]
			  @instru.add accord
				@instru.to_llp.should == "\\relative c' { <c ees g> }"
				@instru.add accord, :duree => 4
				@instru.to_llp.should == 
					"\\relative c' { <c ees g> } \\relative c' { <c ees g>4 }"
			end
			
			# :add_as_motif
			it "doit répondre à :add_as_motif" do
			  @instru.should respond_to :add_as_motif
			end
			it ":add_as_motif doit ajouter le motif" do
				motif = Motif::new "a( b c b a)"
			  @instru.add motif
				@instru.to_llp.should == "\\relative c' { a( b c b a) }"
			end
			
		end

		# -------------------------------------------------------------------
		# 	Tests complet de :add_notes
		# 
		# 	C'est la méthode principale d'ajouts de notes à l'instrument
		# -------------------------------------------------------------------
		describe "Méthode principale :add_notes" do
			def init_notes
				iv_set(@instru, :motifs => [])
			end
			def notes_instru
				iv_get(@instru, :motifs)
			end
			it "doit exister" do
			  @instru.should respond_to :add_notes
			end
			it "doit lever une erreur si mauvais paramètres" do
				err = detemp(Liby::ERRORS[:bad_params_in_add_notes_instrument],
											:instrument => @instru.name,
											:params			=> "bad")
			  expect{@instru.add_notes("bad")}.to raise_error(SystemExit, err)
			end
			it ":doit ajouter des notes simples" do
				init_notes
				mot1 = Motif::new "a b c"
				mot2 = Motif::new "d e f"
				# puts "= motif 1: #{mot1.inspect}"
				# puts "= motif 2: #{mot2.inspect}"
				@instru.add_notes mot1
				@instru.to_llp.should == "\\relative c' { a b c }"
				iv_get(@instru, :motifs).count.should == 1
				@instru.add_notes mot2
				iv_get(@instru, :motifs).count.should == 2
				@instru.to_llp.should == 
					"\\relative c' { a b c } \\relative c' { d e f }"
			end
			
		end
		# -------------------------------------------------------------------
		# 	Méthodes de construction du score Lilypond
		# -------------------------------------------------------------------
		describe "vers score lilypond" do
			before(:all) do
			  SCORE = Score::new unless defined? SCORE
			end
			# :motifs_to_llp
			it "doit répondre à :motifs_to_llp" do
			  @instru.should respond_to :to_llp
			end
			# :to_lilypond
		  it "doit répondre à to_lilypond" do
		    @instru.should respond_to :to_lilypond
		  end
			it ":to_lilypond doit retourner un code valide" do
			  score = @instru.to_lilypond
				score.class.should == String
				score.should == 
					"\\new Staff {\n\t\\relative c' {" \
					<< "\n\t\t\\clef \"treble\"" \
					<< "\n\t\t\\time 4/4\n\t\t" \
					<< "\n\t}\n}"
				suite = "c d e f g a b c"
				@instru << suite
				@instru.to_lilypond.should == 
					"\\new Staff {\n\t\\relative c' {" \
					<< "\n\t\t\\clef \"treble\"" \
					<< "\n\t\t\\time 4/4\n\t\t" \
					<< "\\relative c' { #{suite} }" \
					<<"\n\t}\n}"
				# @note: des tests plus poussés sont effectués par le biais
				# des partitions.
			end
			it "doit inscrire le code pour les mesures si extrait" do
			  pending "à implémenter"
			end
			
			# :staff_header
			it "doit répondre à :staff_header" do
			  @instru.should respond_to :staff_header
			end
			it ":staff_header doit retourner le bon code" do
				iv_set(@instru, :staff => Staff::new )
			  code = @instru.staff_header
				code.should == "\t\\clef \"treble\"\n\t\\time 4/4\n"
				data = {:time => '6/8', :clef => 'F'}
				iv_set(@instru, :staff => Staff::new(data))
				staff = iv_get(@instru, :staff)
			  code = @instru.staff_header
				code.should == "\t\\clef \"bass\"\n\t\\time 6/8\n"
			end
			
			# :staff_content
			it "doit répondre à :staff_content" do
			  @instru.should respond_to :staff_content
			end
			it ":staff_content doit retourner le bon code" do
				iv_set(@instru, :motifs => [])
				@instru.add_as_string "a( b c)"
			  @instru.staff_content.should_not == ""
				@instru.staff_content.should =~ /a\( b c\)/
			end
			
			# :mark_relative
			it "doit répondre à :mark_relative" do
			  @instru.should respond_to :mark_relative
			end
			it ":mark_relative doit renvoyer la bonne valeur" do
			  @i = Voice::new # par défaut car non défini dans Voice:Class
				@i.mark_relative.should == "\\relative c'"
				une_basse = Bass::new
				une_basse.mark_relative.should == "\\relative c"
			end
		end # -> score lilypond

	end # / L'instance
	
end