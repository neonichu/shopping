require File.expand_path('../spec_helper', __FILE__)

module Shopping
	describe Parser do
		it 'can parse a commit' do
			commit = '"40abed6e58b4864afac235c3bb2552e23bc9da47"'
			match = Resolved.parse(commit, :root => :commit)
			match.should.not == nil
		end

		it 'can parse a simple Cartfile.resolved' do
			match = Parser.parse_resolved('spec/fixtures/TestCartfile.resolved')

			match.first.commit.should == nil
			match.first.name.should == 'ReactiveCocoa'
			match.first.repo.should == 'github'
			match.first.tag.should == 'v2.3.1'
			match.first.url.should == 'https://github.com/ReactiveCocoa/ReactiveCocoa.git'

			match.last.commit.should == '40abed6e58b4864afac235c3bb2552e23bc9da47'
			match.last.name.should == 'Mantle'
			match.last.repo.should == 'git'
			match.last.tag.should == nil
			match.last.url.should == 'https://github.com/Mantle/Mantle.git'
		end
	end
end