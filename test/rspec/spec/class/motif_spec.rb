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
		it "avec argument hash pour définir le motif et l'octave" do
		  @m = Motif::new :notes => "d b a", :octave => 4
			iv_get(@m, :notes).should 	== "d b a"
			iv_get(@m, :octave).should 	== 4
		end
  end
	describe "<motif>" do
		before(:each) do
		  @m = Motif::new
		end
		after(:each) do
		  $DEBUG_ON = false
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

			mo = Motif::new
			mo.set_with_string "c4."
			mo.notes.should == "c"
			mo.duration.should == "4."
			mo.octave.should == 3
			
			mo = Motif::new
			mo.set_with_string "cbb( e4 g#) <c e g>8"
			mo.notes.should == "ceses( e4 gis) <c e g>8"
			mo.duration.should be_nil
			mo.octave.should == 3
		end
		
		# :set_with_hash
		it "doit répondre à :set_with_hash" do
		  @m.should respond_to :set_with_hash
		end
		it ":set_with_hash doit définir correctement le motif" do
		  @m.set_with_hash(:notes => "g e c", :duration => 8, :octave => -6)
			@m.notes.should == "g e c"
			@m.duration.should == "8"
			@m.octave.should == -6
		end
		it ":set_with_hash doit lever une erreur en cas de mauvais arguments" do
		  pending "à implémenter"
		end
		
		# :to_s
	  it "doit répondre à :to_s" do repond_a :to_s end
		it ":to_s doit renvoyer nil si le motif n'est pas défini" do
			iv_set(@m, :notes => nil)
		  @m.to_s.should be_nil
		end
		it ":to_s doit renvoyer le motif s'il est défini" do
		  iv_set(@m, :notes => "a b c")
			@m.to_s.should == "\\relative c''' { a b c }"
		end
		it ":to_s doit renvoyer le motif avec une durée si elle est définie" do
		  iv_set(@m, :notes => "c d e")
			@m.to_s(1).should == "\\relative c''' { c1 d e }"
		end
		it ":to_s doit renvoyer le motif à la bonne hauteur d'octave" do
		  iv_set(@m, :notes => "c d e")
			@m.to_s(:octave => -2).should == "\\relative c,, { c d e }"
		end
		it ":to_s doit renvoyer la bonne valeur avec deux motifs de même octave" do
		  @m1 = Motif::new :notes => "a a a", :octave => 3
		  @m2 = Motif::new :notes => "b b b", :octave => 3
			(@m1 + @m2).to_s.should == "\\relative c''' { a a a b b b }"
		end
		it ":to_s doit renvoyer la bonne valeur avec deux motifs d'octave différente" do
		  @m1 = Motif::new :notes => "a a a", :octave => 3
		  @m2 = Motif::new :notes => "b b b", :octave => 2
			(@m1 + @m2).to_s.should == "\\relative c''' { a a a b, b b }"
		end
		it ":to_s avec octave défini doit renvoyer la bonne valeur avec deux motifs d'octave définis" do
		  @m1 = Motif::new :notes => "a a a", :octave => 5
			@m2 = Motif::new :notes => "c c c", :octave => 3
			(@m1 + @m2).to_s(:octave => 1, :duree => 8).should ==
				"\\relative c' { a8 a a c,,, c c }"
			(@m2 + @m1).to_s(:octave => 1, :duree => 8).should ==
				"\\relative c' { c8 c c a''' a a }"
		end
		
		# :first_note
		it "d oit répondre à :first_note" do
		  @m.should respond_to :first_note
		end
		it ":first_note d oit renvoyer la première note" do
			Motif::new("aes b c").first_note.should == "aes"
			Motif::new("a b c").first_note.should == "a"
		  Motif::new("r r aes b c").first_note.should == "aes"
		end
		# :last_note
		it "d oit répondre à :last_note" do
		  @m.should respond_to :last_note
		end
		it ":last_note d oit renvoyer la dernière note" do
		  Motif::new("a b cis").last_note.should == "cis"
		  Motif::new("a b c").last_note.should == "c"
			Motif::new("r a( b ces r)").last_note.should == "ces"
		end
		# :first_et_last_note
		it "d oit répondre à :first_et_last_note" do
		  @m.should respond_to :first_et_last_note
		end
		it ":first_et_last_note d oit retourner la bonne valeur" do
		  Motif::new("r r aes b c").first_et_last_note.should == ["aes", "c"]
			mo = Motif::new("r a( b ces r)")
			mo.first_et_last_note.should == ["a", "ces"]
			mo = Motif::new("r r aeses( b fis fisis) r r")
			mo.first_et_last_note.should == ["aeses", "fisis"]
		end
		
		# :change_durees_in_motif
		it "doit répondre à :notes_with_duree" do
		  @m.should respond_to :notes_with_duree
		end
		it ":notes_with_duree doit changer la durée des notes du motif" do
		  @m = Motif::new "a b c des e4"
			@m.notes_with_duree(2).should == "a2 b c des e4"
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
		
		# :mark_relative
		it "doit répondre à :mark_relative" do
		  @m.should respond_to :mark_relative
		end
		it ":mark_relative sans argument doit retourner la valeur d'octave du motif" do
		  iv_set(@m, :octave => 2)
			@m.mark_relative.should === "\\relative c''"
		end
		it ":mark_relative avec argument doit ajouter le nombre d'octave" do
		  iv_set(@m, :octave => 2)
			@m.mark_relative(0).should 	== "\\relative c''"
			@m.mark_relative(-2).should == "\\relative c"
			@m.mark_relative(2).should	== "\\relative c''''"
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
			(@m1 + @m2).to_s.should == "\\relative c''' { c d e f g a }"
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
		it ":+ permet d'ajouter une note (Note) à un motif et produire un nouveau motif" do
		  n = Note::new "c'''"
			m = Motif::new "c d e"
			res = (m + n)
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { c d e c }"
			# @todo: plus tard, devra être égal à :
			# res.to_s.should == "\\relative c''' { c d e c }"
		end
		# Note: le traitement de l'ajout d'un motif et d'une note est
		# traité dans '+' de la note
		
		it ":+ doit permettre d'ajouter un accord à un motif" do
		  mo = Motif::new "c d e"
			ac = Chord::new "c e g"
			res = mo + ac
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { c d e <c e g> }"
		end
		it ":+ avec un type invalide doit lever une erreur fatale" do
			mo = Motif::new "c d e"
		  h = {:un => "un", :deux => "deux" }
			err = detemp(Liby::ERRORS[:cant_add_this], :classe => h.class.to_s)
			expect{mo + h}.to raise_error(SystemExit, err)
		end
		
		# :join 
		it "d oit r espond à :join" do
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
		  @m1 = Motif::new "c e g"
			(@m1 * 3).should == "\\relative c''' { c e g } " 		\
													<< "\\relative c''' { c e g } "	\
													<< "\\relative c''' { c e g }"
			# @todo: plus tard, devra être égal à :
			# (@m1 * 3).should == "\\relative c'' { c e g c, e g c, e g }"
		end
		
		# :pose_first_and_last_note
		it "doit répondre à :pose_first_and_last_note" do
		  repond_a :pose_first_and_last_note
		end
		it ":pose_first_and_last_note doit poser les balises" do
		  @mo = Motif::new "a b c d"
			res = @mo.pose_first_and_last_note('IN', 'OUT')
			res.should == "aIN b c dOUT"
			res = @mo.pose_first_and_last_note('(', ')')
			res.should == "a( b c d)"
			res = @mo.pose_first_and_last_note('\(', '\)')
			res.should == "a\\( b c d\\)"
		end
		
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
		
		# :moins
		it "doit répondre à :moins" do repond_a :moins end
		it ":moins doit retourner l'objet" do
		  @m.moins(1).class.should == Motif
		end
		it ":moins doit donner le motif avec les demi-tons en moins" do
			iv_set(SCORE, :key => nil)
			@m = Motif::new "bb g f e,4 bb8"
		  @m.moins(1).to_s.should == "\\relative c''' { a fis e ees,4 a8 }"
			@m.moins(2).to_s.should == "\\relative c''' { aes f ees d,4 aes8 }"
			iv_set(SCORE, :key => 'G')
		  @m.moins(1).to_s.should == "\\relative c''' { a fis e dis,4 a8 }"
			@m.moins(2).to_s.should == "\\relative c''' { gis f dis d,4 gis8 }"
		end
		it ":moins doit respecter l'octave du motif" do
			notes = 'a fis e ees r'
		  mo = Motif::new :notes => notes, :octave => 0
			mo.moins(0).to_s.should == "\\relative c { a fis e dis r }"
			mo = Motif::new :notes => notes, :octave => -2
			mo.moins(2).to_s.should == "\\relative c,, { g e d cis r }"
		end
		it ":moins doit pouvoir spécifier l'octave explicitement" do
		  notes = "a fis r gis"
			mo = Motif::new :notes => notes, :octave => 3
			mo.to_s.should == "\\relative c''' { #{notes} }"
			res = mo.moins(0, :octave => 0).to_s
			res.should == "\\relative c { #{notes} }"
			res = mo.moins(0, :octave => -2).to_s
			res.should == "\\relative c,, { #{notes} }"
			res = mo.moins(2, :octave => 1).to_s
			p1 = "\\relative c' { g e r fis }"
			p2 = "\\relative c' { g e r ges }"
			[p1, p2].should include(res)
			
		end
		
		# :plus
		it "doit répondre à :plus" do repond_a :plus end
		it ":plus doit retourner l'objet" do
		  @m.plus(1).class.should == Motif
		end
		it ":plus doit donner le motif supérieur" do
			iv_set(SCORE, :key => nil)
		  @m.plus(1).to_s.should == "\\relative c''' { b aes fis f,4 b8 }"
			@m.plus(2).to_s.should == "\\relative c''' { c a g fis,4 c8 }"
			iv_set(SCORE, :key => 'Bb')
		  @m.plus(1).to_s.should == "\\relative c''' { b aes ges f,4 b8 }"
			@m.plus(2).to_s.should == "\\relative c''' { c a g ges,4 c8 }"
		end
		it ":plus avec le paramètre :new => false doit modifier l'objet" do
		  @motif = Motif::new "c d e"
			@motif.plus(1)
			iv_get(@motif, :notes).should == "c d e"
			@motif.plus(1, :new => false)
			iv_get(@motif, :notes).should == "des ees f"
		end
	
		# :legato
		it "doit répondre à :legato" do repond_a :legato end
		it ":legato doit renvoyer une instance du motif" do
		  @m.legato.class.should == Motif
		end
		it ":legato doit renvoyer une valeur modifiée" do
		  @mo = Motif::new "a b cis r4 a-^ |"
			res = @mo.legato
			res.to_s.should == "\\relative c''' { a( b cis r4 a-^) }"
		end
		it ":legato avec :new => true doit renvoyer un nouveau motif" do
		  @mo = Motif::new "a b d"
			@mo.legato
			iv_get(@mo, :notes).should == "a( b d)"
		  @mo = Motif::new "a b d"
			@mo.legato(:new => true)
			iv_get(@mo, :notes).should == "a b d"
		end

		# :surlegato
		it "doit répondre à :surlegato" do repond_a :surlegato end
		it ":surlegato doit renvoyer une instance du motif" do
		  @m.surlegato.class.should == Motif
		end
		it ":surlegato doit renvoyer une valeur modifiée" do
		  @mo = Motif::new "a b cis r4 a-^ |"
			res = @mo.surlegato
			res.to_s.should == "\\relative c''' { a\\( b cis r4 a-^\\) }"
		end
		
		# :crescendo
		it "doit répondre à :crescendo" do
		  repond_a :crescendo
		end
		it ":crescendo sans argument doit définir le motif simple" do
		  @motif = Motif::new "a b c"
			new_motif = @motif.crescendo
			@motif.to_s.should == "\\relative c''' { a b c }"
			new_motif.to_s.should == "\\relative c''' { a\\< b c\\! }"
			new_motif = @motif.crescendo(:new => false)
			@motif.to_s.should == "\\relative c''' { a\\< b c\\! }"
		end
		it ":crescendo avec :start doit définir la dynamique de départ" do
		  @motif = Motif::new "a b c"
			@motif.crescendo(:new => false, :start => 'pp', :end => 'ff')
			@motif.to_s.should == "\\relative c''' { \\pp a\\< b c \\ff }"
		end
		it ":crescendo avec :end doit définir la dynamique de fin" do
		  @motif = Motif::new "a b c"
			@motif.crescendo(:new => false, :end => 'fff')
			@motif.to_s.should == "\\relative c''' { a\\< b c \\fff }"
		end
		
		# :decrescendo
		it "doit répondre à :decrescendo" do
		  repond_a :decrescendo
		end
		it ":decrescendo sans argument doit définir le motif simple" do
		  @motif = Motif::new "a b c"
			new_motif = @motif.decrescendo
			@motif.to_s.should == "\\relative c''' { a b c }"
			new_motif.to_s.should == "\\relative c''' { a\\> b c\\! }"
			@motif.decrescendo(:new => false)
			@motif.to_s.should == "\\relative c''' { a\\> b c\\! }"
		end
		it ":decrescendo avec :start doit définir la dynamique de départ" do
		  @motif = Motif::new "a b c"
			@motif.decrescendo(:new => false, :start => 'fff', :end => 'ppp')
			@motif.to_s.should == "\\relative c''' { \\fff a\\> b c \\ppp }"
		end
		it ":decrescendo avec :end doit définir la dynamique de fin" do
		  @motif = Motif::new "a b c"
			@motif.decrescendo(:new => false, :end => 'ppp')
			@motif.to_s.should == "\\relative c''' { a\\> b c \\ppp }"
		end
		
		
	end # / transformation du motif
end