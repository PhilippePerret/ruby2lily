# 
# Pour tous les tests d'addition sur les :
# 	- String
# 	- Note
# 	- Motif
# 	- Accord
require 'spec_helper'
require 'noteclass'
require 'string'
require 'note'
require 'linote'
require 'motif'
require 'chord'

# -------------------------------------------------------------------
# 	Méthode générale NoteClass#+
# -------------------------------------------------------------------
describe "NoteClass#+" do
  it "doit exister" do
    NoteClass::new.should respond_to :+
  end
end
# -------------------------------------------------------------------
# 	String
# -------------------------------------------------------------------
describe "Addition à String" do

  describe "String + String" do
    it "doit retourner un Motif contenant les notes" do
      res = "a" + "b"
			res.class.should == Motif
			res.notes.should == "a b"
			res = "a" + "bb" + "dois" + "la#"
			res.class.should == Motif
			res.notes.should == "a bes cis, ais'"
			res = "a'" + "bb"
			res.class.should == Motif
			res.notes.should == "a bes,"
			res.octave.should == 4
    end
  end
	describe "String + Note" do
		it "doit retourner un motif contenant les notes" do
		  no = Note::new( "c" )
			res = "a" + no
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { a c, }"
		end
	end
	describe "String + Motif" do
	  it "doit retourner un motif (simple) contenant les notes" do
	    mo = Motif::new("d")
			res = "c" + mo
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { c d }"
	  end
		it "doit retourner un motif (semi-complexe) contenant les notes" do
		  mo = Motif::new(:notes => "d e4 f,", :duree => 8, :octave => 1)
			res = "c c," + mo
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { c c, d,8 e4 f, }"
		end
		it "doit retourner un motif (complexe) contenant les notes" do
		  # @todo: implémenter le motif complexe (note : le faire partout)
			# (un motif complexe comprend toutes les marques possibles pour 
			# les notes, c'est-à-dire, ici, le jeu et le doigté, ainsi que
			# la dynamique)
		end
	end
	describe "String + Chord" do
		it "doit retourner un motif (simple) contenant les notes" do
		  acc = Chord.new ["c", "e", "g"]
		  res = "c" + acc
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { c <c e g> }"
			res = "c e g c" + acc[6]
			res.to_s.should == "\\relative c''' { c e g c <c'' e g> }"
			res = "<c e g> c8" + acc["4", 3]
			res.to_s.should == "\\relative c''' { <c e g> c8 <c, e g>4 }"
		end
	end
end

# -------------------------------------------------------------------
# 	Note
# -------------------------------------------------------------------
describe "Addition à Note" do
	
  describe "Note + String" do
		it "doit renvoyer un motif conforme" do
		  n = Note::new "c"
			res = (n + "a'")
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { c a'' }"
		end
		it "autres tests Notes + String" do
			no = Note::new "c##"
			res = no + "<c d e> r g"
		  res.class.should == Motif
			res.to_s.should == "\\relative c''' { cisis <c d e> r g }"
		end
  end
	describe "Note + Note" do
	  it "doit renvoyer un motif" do
	    no1 = Note::new "c"
			no2 = Note::new "d"
			res = no1 + no2
			res.class.should == Motif
			res.notes.should == "c d"
			res.octave.should == 3
			res.duration.should be_nil
	  end
		it "+ Note doit produire un nouveau motif" do
		  nut = ut
			nre = re
			nmi = mi
			res = (nut + nre + nmi)
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { c d e }"
		end
		it "avec différents octaves doit produire le bon résultat" do
		  nut = ut :octave => 1
			nre = re :octave => 2
			mo = nut + nre
			mo.class.should == Motif
			mo.to_s.should == "\\relative c' { c d' }"
		end
		
	end
	describe "Note + Motif" do
		it "doit renvoyer un motif conforme" do
		  n = Note::new "c"
			m = Motif::new "e d"
			res = (n + m)
			res.class.should 				== Motif
			res.notes.class.should 	== String
			res.to_s.should == "\\relative c''' { c e d }"
		end
	end
	describe "Note + Chord" do
	  it "doit retourner un motif conforme" do
	    
			# Note simple
			no = Note::new "c"
			acc = Chord::new ["c e g"]
			(no + acc).to_s.should == "\\relative c''' { c <c e g> }"

			# Note altérée
			no = Note::new "c##"
			res = no + acc
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { cisis <c e g> }"
			
			# Note altérée avec delta d'octave
			no = Note::new "c##,"
			(no + acc).to_s.should == "\\relative c'' { cisis <c' e g> }"
			
	  end
	end
end

# -------------------------------------------------------------------
# 	Motif
# -------------------------------------------------------------------
def define_motifs
  @motif_simple 	= Motif::new("c e g")
	@motif_octave_2 = Motif::new(:notes => "c e g", :octave => 2)
	# Motif avec une octave différente à la fin qu'au début
	@mo_octave_diff = Motif::new(:notes => "a c e a")
	# Motif simple avec accord
	@mo_accord			= Motif::new(:notes => "<a c e>")
	# Motif avec accord et silence
	@mo_chord_et_rest = Motif::new(:notes => "r <b d fis> r g")
	# Motif avec liaison de jeu
	@mo_slur = Motif::new(:notes => "a( b c d) e( f g) r", :octave => -1)
	# Motif avec liaison de jeu en propriété (@todo)
	@mo_slured = Motif::new(:notes => "a b c d e", :slured => true)
	# Motif complexe
	@mo_complex = Motif::new(
		# :notes 	=> "r\\( <ais c e> geses8( b[ e4])\\) r2",
		:notes => "r\\( <ais c e> geses8( b[ e4])\\) r2",
		:octave => 2, :duration => "4"
		)
end
describe "Addition et Motif" do
	before(:all) do
	end
  describe "Motif + String" do
		define_motifs if @mo_slured.nil?
	  [
			# Motif simple
			[@motif_simple, "c", "\\relative c''' { c e g c, }"],
			[@motif_octave_2, "c", "\\relative c'' { c e g c }"],
			[@mo_octave_diff, "c", "\\relative c''' { a c e a c,, }"],
			[@mo_accord, "a''", "\\relative c''' { <a c e> a' }"],
			[@mo_chord_et_rest, "r r c,", "\\relative c''' { r <b d fis> r g r r c,,, }"],
			[@mo_chord_et_rest, "r c,", "\\relative c''' { r <b d fis> r g r c,,, }"],
			[@mo_chord_et_rest, "c,", "\\relative c''' { r <b d fis> r g c,,, }"],
			[@mo_slur, "a'( b c)", "\\relative c, { a( b c d) e( f g) r a''''( b c) }"],
			[@mo_slured, "<a c e>", "\\relative c''' { a( b c d e) <a, c e> }"],
			[@mo_complex, "cisis( ges ges4)", "\\relative c'' { r4\\( <ais c e> geses8( b[ e4])\\) r2 cisis,( ges ges4) }"]
		].each do |d|
			motif, str, res = d
			it "Motif « #{motif.notes} » (octave #{motif.octave}) + String « #{str} »" do
			 	new_mo = motif + str
				new_mo.class.should == Motif
				new_mo.object_id.should_not == motif.object_id
				new_mo.to_s.should == res
			end
		end
  end
	describe "Motif + Note" do
	  pending "à implémenter"
	end
	describe "Motif + Motif" do
	  pending "à implémenter"
	end
	describe "Motif + Chord" do
	  pending "à implémenter"
	end
end

# -------------------------------------------------------------------
# 	Chord
# -------------------------------------------------------------------
describe "Addition et Chord" do
	describe "Généralités" do
	  it "doit répondre à :+" do
	    Chord::new("a c e").should respond_to :+
	  end
	end
  describe "Chord + String doit réussir" do
    it "doit réussir avec un accord simple et un string simple" do
      acc = Chord::new "a c e"
			str = "b"
			res = acc + str
			res.class.should == Motif
			res.to_s.should == "\\relative c''' { <a c e> b }"
    end
		it "doit réussir avec un accord dont on change l'octave et la durée" do
		  lam = Chord::new "a c e"
			str = "c'" # donc à l'octave 4
			res = lam[2,"8"] + str # donc à l'octave 2
			res.class.should == Motif
			res.to_s.should == "\\relative c'' { <a c e>8 c' }"
			
			res = lam[blanche, -2] + str
			res.class.should == Motif
			res.to_s.should == "\\relative c,, { <a c e>2 c''''' }"
		end
  end
	describe "Chord + Note" do
	  it "Une note d oit pouvoir être ajoutée à un accord" do
	    pending "à implémenter"
	  end
	end
	describe "Chord + Motif" do
	  it "un motif d oit pouvoir être ajouté à un accord" do
	    pending "à implémenter"
	  end
	end
	describe "Chord + Chord" do
	  it "un accord d oit pouvoir être ajouté à un accord" do
	    pending "à implémenter"
	  end
	end
	describe "Chord + Autre" do
	  it "d oit lever une erreur fatale" do
	    expect{@chord + 12}.to raise_error
	  end
	end
end
