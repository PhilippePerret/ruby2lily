# 
# Tests de la classe Score (partition)
# 
require 'spec_helper'
require 'score'

describe Score do
  # -------------------------------------------------------------------
	# 	La classe
	# -------------------------------------------------------------------
	describe "La classe" do
		describe "Méthodes générales" do
		  it "doit répondre à :new" do
		    Score.should respond_to :new
		  end
			it ":new doit créer une nouvelle partition" do
			  Score::new.class.should == Score
			end
		end
		describe "Constantes" do
			before(:all) do
			  @defv 	= Score::DEFAULT_VALUES
				@prefs	= Score::PREFERENCES
			end
			it "doit définir ::DEFAULT_VALUES" do
			  defined?(Score::DEFAULT_VALUES).should be_true
			end
			it "DEFAULT_VALUES[:time] doit exister" do
				@defv.should have_key :time
			end
			it "DEFAULT_VALUES[:title] doit être défini" do
			  @defv.should have_key :title
			end
			
			# ::PREFERENCES
			it "doit définir ::PREFERENCES" do
			  defined?(Score::PREFERENCES).should be_true
			end
			it "PREFERENCES[:no_title] doit exister" do
			  @prefs.should have_key :no_title
			end
		end
	end
	
	# -------------------------------------------------------------------
	# L'instance
	# -------------------------------------------------------------------
	describe "L'instance" do
	  before(:each) do
	    @s = Score::new
	  end
	
		# -------------------------------------------------------------------
		# 	Méthodes de définition
		# -------------------------------------------------------------------
		describe "Méthodes de définition" do
		  it "doit répondre à :set" do
		    @s.should respond_to :set
		  end
			it ":set doit définir les données générales" do
				data = {
					:title => "Titre de la partition",
					:composer => "Le compositeur",
					:author		=> "L'auteur des paroles",
					:key			=> G,
					:subtitle	=> nil
				}
			  @s.set data
				data.each do |k, val|
					iv_get(@s, k).should == val
				end
			end
			it ":set doit définir des valeurs par défaut" do
				iv_get(@s, :time).should be_nil
			  data = {
					:author => "me"
				}
				@s.set data
				iv_get(@s, :title).should == Score::DEFAULT_VALUES[:title]
				iv_get(@s, :time).should 	== Score::DEFAULT_VALUES[:time]
			end
		end		
	end
end