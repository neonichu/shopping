require File.expand_path('../spec_helper', __FILE__)

module Shopping
	describe Podfile do
		it 'can convert a Cartfile to a Podfile' do
			result = Parser.parse('spec/fixtures/TestCartfile')
			podfile = Podfile.serialize(result)

			podfile.should == Pathname.new('spec/fixtures/TestPodfile').read
		end

		it 'can convert a Cartfile to a Pod specification fragment' do
			result = Parser.parse('spec/fixtures/TestCartfile')
			podspec = Podspec.serialize(result)

			podspec.should == Pathname.new('spec/fixtures/Test.podspec').read
		end
	end
end