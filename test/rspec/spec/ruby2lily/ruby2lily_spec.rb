# 
# Tests généraux de ruby2lily
# 
require 'spec_helper'
require 'liby'

PATH_RUBY2LILY = File.join(BASE_LILYPOND, 'ruby2lily.rb')

describe "ruby2lily.rb" do
  it "doit exister" do
		File.exists?(PATH_RUBY2LILY).should be_true
  end
end

describe "La commande `ruby2lily' avec des erreurs" do
	def error_sans_color err
		err.strip[7..-5]
	end
	before(:all) do

	end
  it "doit exiter avec une erreur si absence du path du score" do
		cmd = PATH_RUBY2LILY
		err = Liby::ERRORS[:arg_path_file_ruby_needed].strip
		res = `#{cmd}`.strip
		error_sans_color(res).should =~ /#{Regexp.escape(err)}/
  end
	it "doit exiter avec une erreur si path incorrect" do
		bad_path = "mauvais/path.rb"
		cmd = PATH_RUBY2LILY + " '#{bad_path}'"
		err = Liby::error( :arg_score_ruby_unfound, :path => bad_path ).strip
		res = `#{cmd}`.strip
		error_sans_color(res).should =~ /#{Regexp.escape(err)}/
	end
end

describe "La commande `ruby2lily' sans erreur" do
	after(:each) do
	  File.unlink @path_pdf unless @path_pdf.nil? || !File.exists?(@path_pdf)
	end
	
	# =>	Appel ruby2lily en ligne de commande
	# 		et place le résultat (donc tout le texte généré par le programme
	# 		avec les messages) dans @res
	def as_ligne_commande
		cmd = PATH_RUBY2LILY + " '#{@good_score}'"
		@res = `#{cmd}`
	end
	
	# => 	Simule l'appel en ligne de commande, mais charge en fait le
	# 		module, ce qui permet d'avoir toutes les valeurs définies
	def simule_ligne_commande
		# On simule l'appel du module avec un argument
		ARGV.clear
		ARGV << @good_score
		load File.join(BASE_LILYPOND, 'ruby2lily.rb')
	end

	before(:all) do
	  @good_score = 'partition_test.rb'
		@path_pdf		= 'partition_test.pdf'
	end
	describe "Appel en ligne de commande" do
	  before(:all) do
	    as_ligne_commande
	  end
		it "doit renvoyer un message de succès" do
			@res.should =~ /Fichier converti avec succès/	  
		end
	end
	describe "Simulation de l'appel en ligne de commande" do
	  before(:all) do
			simule_ligne_commande
	  end
		it "doit définir les musiciens de l'orchestre" do
			defined?(SALLY).should be_true
			Kernel::SALLY.class.should == Voice
			defined?(PIANO).should be_true
			PIANO.class.should == Piano
			defined?(BATTERIE).should be_true
			BATTERIE.class.should == Drums
			defined?(BASSE).should be_true
			BASSE.class.should == Bass
		end
	end
end