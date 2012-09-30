# 
# Tests de l'explode de LINote
# 

require 'spec_helper'
require 'linote'

describe LINote do
	before(:all) do
	  SCORE = Score::new unless defined? SCORE
		ORCHESTRE = Orchestre::new unless defined? ORCHESTRE
	end
	describe "OCTAVES & DELTA" do
		it ":explode doit exploser une simple note string" do
		  res = LINote::explode "c"
			res.count.should == 1
			res.first.note.should == "c"
			res.first.octave.should == 4
			res.first.delta.should == 0
		end
		it ":explode doit exploser deux simple notes string" do
		  res = LINote::explode "c c"
			res.count.should == 2
			un = res.first
			deux = res[1]
			un.note.should == "c"
			deux.note.should == "c"
			un.octave.should == 4
			deux.octave.should == 4
		end
		it ":explode doit exploser deux simple notes string avec delta positif" do
		  res = LINote::explode "c c'"
			res.count.should == 2
			un = res.first
			deux = res[1]
			un.octave.should == 4
			deux.octave.should == 5
			deux.delta.should == 1
		end
		it ":explode doit exploser deux simple notes string avec delta positif" do
		  res = LINote::explode "c c,,"
			res.count.should == 2
			un = res.first
			deux = res[1]
			un.octave.should == 4
			deux.octave.should == 2
			deux.delta.should == -2
		end
		it ":explode doit exploser une suite avec silence" do
		  res = LINote::explode "c r c'", octave = 0
			res.count.should == 3
			un = res[0]; deux = res[1]; trois = res[2];
			un.octave.should == 0
			deux.octave.should == nil
			trois.octave.should == 1
			trois.delta.should == 1
		end
		it ":explode doit exploser un accord correctement" do
		  res = LINote::explode "<c e g c e g> c"
			un = res[0]; quatre = res[3]; sept = res[6]
			un.octave.should == 4
			quatre.octave.should == 5
			quatre.delta.should == 0
			sept.octave.should == 4
			sept.delta.should == 0
		end
		it ":explode doit exploser un accord correctement" do
		  res = LINote::explode "<c e g c' e g> c,,"
			un = res[0]; quatre = res[3]; sept = res[6]
			un.octave.should == 4
			quatre.octave.should == 6
			quatre.delta.should == 1
			sept.octave.should == 2
			sept.delta.should == -2
		end
		it ":explode avec deux accords qui se suivent" do
		  res = LINote::explode "<c e g c> <d fis a> e", octave = 0
			un = res[1]; quatre = res[3]; cinq = res[4]; sept = res[6]; huit = res[7]
			un.octave.should 			== 0
			quatre.octave.should 	== 1
			cinq.octave.should 		== 0
			cinq.delta.should 		== 0
			sept.octave.should 		== 0
			sept.delta.should 		== 0
			huit.octave.should 		== 0
			huit.delta.should 		== 0 
		end
		it ":explode avec deux accords séparés par un silence" do
		  res = LINote::explode "<c e g c> r <d fis a d>", octave = 1
			un = res[0]; quatre = res[3]; six = res[5]; neuf = res[8]
			un.octave.should == 1
			quatre.octave.should == 2
			six.octave.should_not == 2
			six.octave.should == 1
			six.delta.should == 0
			neuf.octave.should == 2
			neuf.delta.should == 0
		end
		it ":explode avec silence avant note" do
		  res = LINote::explode "r c'", octave = 5
			deux = res[1]
			deux.note.should == "c"
			deux.octave.should == 6
			deux.delta.should  == 0
		end
		it "explode avec silence avant accord" do
		  res = LINote::explode "r <c e g> r <a c e> r e''", octave = 0
			cun = res[1]
			gun = res[3]
			aun = res[5]
			ede = res[7]
			etr = res[9]
			cun.note.should 	== "c"
			cun.octave.should == 0
			cun.delta.should 	== 0
			gun.note.should 	== "g"
			gun.octave.should == 0
			aun.note.should 	== "a"
			aun.octave.should == -1
			aun.delta.should 	== 0
			ede.note.should 	== "e"
			ede.octave.should == 0
			ede.delta.should 	== 0
			etr.note.should 	== "e"
			etr.delta.should 	== 2
			etr.octave.should == 1
		end
	end

end