# 
# Tests de la class Voice < Instrument
# 
require 'spec_helper'
require 'instruments/voice'

describe Voice do
	before(:all) do
	  SCORE = Score::new unless defined? SCORE
		ORCHESTRE = Orchestre::new unless defined? ORCHESTRE
	end
  # -------------------------------------------------------------------
	# Classe
	# -------------------------------------------------------------------
	describe "La classe" do
	  it "doit répondre à :new" do
	    Voice.should respond_to :new
	  end
		it ":new doit renvoyer une voice" do
		  Voice.new.class.should == Voice
		end
		it "doit répondre à :uname" do
		  Voice.should respond_to :uniq_name
		end
		it ":uname doit retourner un nom unique" do
		  Voice.uniq_name.should == "voice_unnamed_1"
			Voice.uniq_name.should == "voice_unnamed_2"
		end
	end # / La classe
	
	# -------------------------------------------------------------------
	# 	L'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @voice = Voice::new
	  end
		describe "Méthodes générales" do
		  it "doit répondre à :uniq_name" do
		    @voice.should respond_to :uniq_name
		  end
			it ":uniq_name doit renvoyer la bonne valeur" do
				current = cv_get(Voice, :index_voice)
			  @voice.uniq_name.should == "voice_unnamed_#{current + 1}"
				iv_set(@voice, :name => "Ma_Voix", :uniq_name => nil)
			  @voice.uniq_name.should == "ma_voix"
			end
			it ":uniq_name doit supprimer tout ce qui n'est pas a-z_" do
			  iv_set(@voice, :name => "Une très mauvaise voix, ça…")
				@voice.uniq_name.should == "une_trs_mauvaise_voix_a"
			end
		end
		describe "Génération du code LilyPond" do
		  it "doit répondre à :to_lilypond" do
		    @voice.should respond_to :to_lilypond
				# @note: le fait de toute façon, par la classe mère Instrument
		  end
			it ":to_lilypond doit retourner un code particulier" do
			  res = @voice.to_lilypond
				name = @voice.uniq_name
				res.should =~ /new Voice = "#{name}"/
				res[0..20].should =~ /<</
				res[-20..-1].should =~ />>/
				res.should =~ /\\new Lyrics \\lyricsto "#{name}"/
			end
			it ":to_lilypond doit écrire les notes et les accords" do
			  @voice << "c8 c c d e4 d"
				@voice.paroles << "Au clair de la lu- ne"
				res = @voice.to_lilypond
				res.should =~ /c8 c c d e4 d/
				res.should =~ /Au clair de la lu- ne/
			end
		end
		
		describe "Paroles" do
		  it "doit répondre à :paroles et :lyrics" do
		    @voice.should respond_to :paroles
				@voice.should respond_to :lyrics
		  end
			it "@paroles doit être une instance Voice::Lyrics" do
			  paroles = @voice.paroles
				paroles.class.should == Voice::Lyrics
			end
			it "@paroles doit répondre à :add et :<<" do
			  paroles = @voice.paroles
				paroles.should respond_to :add
				paroles.should respond_to :<<
				# @NOTE: les autres tests sont faits ci-dessous, pour 
				# Voice::Lyrics
			end
			it "On doit pouvoir ajouter des paroles à la Voice" do
			  @voice.paroles.add "Mes paroles"
				@voice.paroles << "et autres paroles"
				@voice.paroles.to_s.should == "Mes paroles et autres paroles"
			end
		end
		
	end # / L'instance
	
	describe "Voice::Lyrics" do
		before(:each) do
		  @vl = Voice::Lyrics::new
		end
	  it "doit répondre à :add et :<<" do
	    @vl.should respond_to :add
			@vl.should respond_to :<<
	  end
		it ":add doit ajouter des paroles" do
		  @vl.add "Mes pa- ro- les"
			iv_get(@vl, :lyrics).should == "Mes pa- ro- les"
			@vl.add "et suivantes"
			iv_get(@vl, :lyrics).should == "Mes pa- ro- les et suivantes"
		end
		it "doit répondre à :to_s" do
		  @vl.should respond_to :to_s
		end
		it ":to_s doit retourner les paroles en string" do
		  @vl.add "Mes paroles"
			@vl.to_s.should == "Mes paroles"
		end
	end
end