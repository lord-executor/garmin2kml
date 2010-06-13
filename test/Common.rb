
current_dir = File.expand_path(File.dirname(__FILE__))

$LOAD_PATH << current_dir
$LOAD_PATH << File.join(current_dir, "../lib")

require("rubygems")
require("test/unit")

