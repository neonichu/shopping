require 'citrus'

grammars = ::File.expand_path(::File.join('..', 'grammars'), __FILE__)
$LOAD_PATH.unshift(grammars) unless $LOAD_PATH.include?(grammars)

Citrus.require 'Cartfile'

module Shopping
	class Dependency
		attr_reader :branch
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
			@repo == "git" ? @path : "https://github.com/#{@path}"			
		end

		def to_s
			"#{name} #{version}"
		end

		private

		def unquote(string)
			string.first.to_s.split('"')[1]
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
	end
end
