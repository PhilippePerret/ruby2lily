# 
# Tests de la classe Instrument
# 
require 'spec_helper'
require 'instrument'

describe Instrument do
	before(:all) do
	  SCORE = Score::new unless defined? SCORE
		iv_set(SCORE, :key => nil)
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
  end # /la classe

	# -------------------------------------------------------------------
	# Tests de l'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @instru = Instrument::new( {} )
	  end
	
		describe "Sous-instances" do
			# # :accord / :accords
			# it "doit répondre à :accord et :chord" do
			#   @instru.should respond_to :accord
			# 	@instru.should respond_to :chord
			# end
			# it ":accord doit renvoyer une instance de class Accord" do
			#   @instru.accord.class.should == Chord
			# end
			# it "doit répondre à :accords et :chords" do
			#   @instru.should respond_to :accords
			# 	@instru.should respond_to :chords
			# end

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
			# # :mesure / :mesures
			# it "doit répondre à :mesure et :measure" do
			#   @instru.should respond_to :mesure
			# 	@instru.should respond_to :measure
			# end
			# it ":mesure doit retourner une instance de classe Mesure" do
			#   @instru.mesure.class.should == Measure
			# end
			it "doit répondre à :mesures et :measures" do
			  @instru.should respond_to :mesures
			  @instru.should respond_to :measures
			end
			it ":mesures doit renvoyer les mesures demandées" do
			  voix = Voice::new()
				voix << "a4 b c d eis4-^ f g a"
				res = voix.mesures(2, 2)
				res.to_s.should == "eis4-^ f g a"
			end

			# # :motif / :motifs
			# it "doit répondre à :motif" do
			#   @instru.should respond_to :motif
			# end
			# it ":motif doit retourner une instance de classe Motif" do
			#   @instru.motif.class.should == Motif
			# end
			# it "doit répondre à :motifs" do
			#   @instru.should respond_to :motifs
			# end
		end # / sous-instances

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