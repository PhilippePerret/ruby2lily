# 
# Tests de la classe Instrument
# 
require 'spec_helper'
require 'instrument'

describe Instrument do
	
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
			# :accord / :accords
			it "doit répondre à :accord et :chord" do
			  @instru.should respond_to :accord
				@instru.should respond_to :chord
			end
			it ":accord doit renvoyer une instance de class Accord" do
			  @instru.accord.class.should == Chord
			end
			it "doit répondre à :accords et :chords" do
			  @instru.should respond_to :accords
				@instru.should respond_to :chords
			end

			# :mesure / :mesures
			it "doit répondre à :mesure et :measure" do
			  @instru.should respond_to :mesure
				@instru.should respond_to :measure
			end
			it ":mesure doit retourner une instance de classe Mesure" do
			  @instru.mesure.class.should == Measure
			end
			it "doit répondre à :mesures et :measures" do
			  @instru.should respond_to :mesures
			  @instru.should respond_to :measures
			end

			# :motif / :motifs
			it "doit répondre à :motif" do
			  @instru.should respond_to :motif
			end
			it ":motif doit retourner une instance de classe Motif" do
			  @instru.motif.class.should == Motif
			end
			it "doit répondre à :motifs" do
			  @instru.should respond_to :motifs
			end
		end # / sous-instances

		# -------------------------------------------------------------------
		# 	Méthodes de définition de la partition
		# -------------------------------------------------------------------
		describe "Définition de la partition" do
			before(:each) do
			  iv_set(@instru, :notes => nil)
			end
			# :add
		  it "doit répondre à la méthode :add" do
		    @instru.should respond_to :add
		  end
			it ":add doit accepter des notes en string" do
			  @instru.add "a b c"
			end
			
			# :add_as_string
			it "doit répondre à :add_as_string" do
			  @instru.should respond_to :add_as_string
			end
			it ":add_as_string doit ajouter les notes" do
				iv_set(@instru, :notes => "")
			  @instru.add notes
				iv_get(@instru, :notes).should == notes
				@instru.add "fb b##"
				iv_get(@instru, :notes).should == notes + " fes bisis"
			end
			
			# :add_as_chord
			it "doit répondre à :add_as_chord" do
			  @instru.should respond_to :add_as_chord
			end
			it ":add_as_chord doit ajouter l'accord" do
			  @instru.add accord
				iv_get(@instru, :notes).should == accord
			end
			
			# :add_as_motif
			it "doit répondre à :add_as_motif" do
			  @instru.should respond_to :add_as_motif
			end
			it ":add_as_motif doit ajouter le motif" do
			  @instru.add motif
				iv_get(@instru, :notes).should == motif
			end
		end

		# -------------------------------------------------------------------
		# 	Méthodes de construction du score Lilypond
		# -------------------------------------------------------------------
		describe "vers score lilypond" do
			before(:all) do
			  SCORE = Score::new unless defined? SCORE
			end
			# :as_lilypond_score
		  it "doit répondre à as_lilypond_score" do
		    @instru.should respond_to :as_lilypond_score
		  end
			it ":as_lilypond_score doit retourner un code valide" do
			  score = @instru.as_lilypond_score
				score.class.should == String
				score.should == ""
			end
			
			# :staff_header
			it "doit répondre à :staff_header" do
			  @instru.should respond_to :staff_header
			end
			it ":staff_header doit retourner le bon code" do
				iv_set(@instru, :staff => Staff::new )
			  code = @instru.staff_header
				code.should == "\t\\clef \"treble\"\n\t\\time \"4/4\"\n"
				data = {:time => '6/8', :clef => 'F'}
				iv_set(@instru, :staff => Staff::new(data))
				staff = iv_get(@instru, :staff)
				debug "staff: #{staff.inspect}"
			  code = @instru.staff_header
				code.should == "\t\\clef \"bass\"\n\t\\time \"6/8\"\n"
			end
			
			# :staff_content
			it "doit répondre à :staff_content" do
			  @instru.should respond_to :staff_content
			end
			it ":staff_content doit retourner le bon code" do
			  @instru.staff_content.should_not == ""
				pending "à implémenter"
			end
		end # -> score lilypond

	end # / L'instance
	
end