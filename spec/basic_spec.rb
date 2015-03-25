require File.expand_path('../spec_helper', __FILE__)

module Shopping
	describe Parser do
		it 'can parse the repository kind of a dependency' do
			match = Cartfile.parse('github', :root => :repo)
			match.should.not == nil
		end

		it 'can parse quoted strings' do
			match = Cartfile.parse('"foo/bar"', :root => :quoted_string)
			match.should.not == nil
		end

		it 'can parse versions' do
			versions = [ '>= 1.0', '== 2.0', '~> 3.1.0' ]

			versions.each do |version|
				match = Cartfile.parse(version.split(' ')[0], :root => :operator)
				match.should.not == nil

				match = Cartfile.parse(version.split(' ')[1], :root => :version)
				match.should.not == nil

				match = Cartfile.parse(version, :root => :version_spec)
				match.should.not == nil
			end
		end

		it 'can parse a dependency' do
			dep = "github \"ReactiveCocoa/ReactiveCocoa\" >= 2.3.1"
			match = Cartfile.parse(dep, :root => :dependency)

			match.should.not == nil
		end

		it 'can parse a dependency with branch' do
			dep = 'git "https://enterprise.local/desktop/git-error-translations.git" "development"'
			match = Dependency.new(Cartfile.parse(dep, :root => :dependency))

			match.name.should == 'git-error-translations'
			match.url.should == 'https://enterprise.local/desktop/git-error-translations.git'
			match.version.should == ''
			match.branch.should == 'development'
		end

		it 'can parse a simple Cartfile' do
			match = Parser.parse('spec/fixtures/TestCartfile')

			match.first.name.should == 'ReactiveCocoa'
			match.first.url.should == 'https://github.com/ReactiveCocoa/ReactiveCocoa'
			match.first.version.should == '>= 2.3.1'
		end
	end
end