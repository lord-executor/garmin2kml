
require("rake")

test_files = FileList.new("./test/Test*.rb")

task(:test) do
	test_files.to_a().each do |file|
		puts("running tests for #{file}")
		require(file)
	end
end
