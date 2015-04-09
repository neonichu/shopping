require 'citrus'

grammars = ::File.expand_path(::File.join('..', 'grammars'), __FILE__)
$LOAD_PATH.unshift(grammars) unless $LOAD_PATH.include?(grammars)

Citrus.require 'Cartfile'
Citrus.require 'Resolved'

module Shopping
	class Dependency
		attr_reader :branch
		attr_reader :repo
		attr_reader :version

		def initialize(dependency_match)
			quoted_string = dependency_match['quoted_string']
			version_spec = dependency_match['version_spec']

			@repo = dependency_match['repo'].first.to_s
			@path = unquote(quoted_string)
			@version = version_spec.first.to_s
			@version = nil if @version.length == 0

			if quoted_string.count == 2
				@branch = unquote([quoted_string[1]])
			end
		end

		def name
			(Pathname.new(@path).basename '.*').to_s
		end

		def url
			@repo == "git" ? @path : "https://github.com/#{@path}.git"			
		end

		def to_s
			"#{name} #{version}"
		end

		private

		def unquote(string)
			string.first.to_s.split('"')[1]
		end
	end

	class ResolvedDependency < Dependency
		attr_reader :commit
		attr_reader :tag

		def initialize(dependency_match)
			super(dependency_match)

			@branch = nil
			@commit = unquote(dependency_match['commit'])
			@tag = unquote(dependency_match['tag'])
			@version = nil
		end
	end

	class Parser
		def self.parse(path)
			Cartfile.parse(Pathname.new(path).read).matches.map do |match|
				dependency = match.captures[:dependency]
				unless dependency.nil? || dependency.first.nil?
					Dependency.new(dependency.first.captures)
				end
			end.compact
		end

		def self.parse_resolved(path)
			Resolved.parse(Pathname.new(path).read).matches.map do |match|
				resolved = match.captures[:resolved_dependency]
				ResolvedDependency.new(resolved.first.captures)
			end
		end
	end

	class Podfile
		def self.serialize(dependencies)
			dependencies.map do |dependency|
				pod = "pod '#{dependency.name}'"

				if (!dependency.branch && !dependency.version) || dependency.repo == 'git'
					pod += ", :git => '#{dependency.url}'"
				end

				pod += ", :branch => '#{dependency.branch}'" if dependency.branch
				pod += ", '#{dependency.version.sub('==', '=')}'" if dependency.version

				pod
			end.join("\n")
		end
	end

	class Podspec
		def self.serialize(dependencies)
			dependencies.map do |dependency|
				pod = "spec.dependency '#{dependency.name}'"
				pod += ", '#{dependency.version.sub('==', '=')}'" if dependency.version

				pod
			end.join("\n")
		end
	end
end
