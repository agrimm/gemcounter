#Build up a suitable list of gems (probably by hand)
#Download statistics for those gems
#Calculate differences between two data sets - done
#Determine the 90th centile - done
#Adjust accordingly

$: << "lib"

require "test/unit"
require "gem_counter"

module TestGemCounterHelper
  def assert_name_and_downloads_are(expected_name, expected_downloads, json_text, failure_message)
    json_parser = JsonParser.new(json_text)
    assert_equal expected_name, json_parser.name, failure_message
    assert_equal expected_downloads, json_parser.downloads, failure_message
  end
  
  def assert_increase_is(expected_increase, older_data_set, newer_data_set, percentile, failure_message)
    gem_statistics_comparer = GemStatisticsComparer.new([older_data_set, newer_data_set])
    actual_increase = gem_statistics_comparer.increase_for(percentile)
    assert_equal expected_increase, actual_increase, failure_message
  end
end

class TestGemCounter < Test::Unit::TestCase
  include TestGemCounterHelper

  def test_json_conversion
    json_text = %q{[{"dependencies":{"runtime":[{"name":"gosu","requirements":">= 0"}],"development":[]},"name":"zombie-chaser","downloads":170,"info":"A zombie-themed graphic(al) user interface for mutation testing","version_downloads":70,"version":"0.0.3","gem_uri":"http://rubygems.org/gems/zombie-chaser-0.0.3.gem","project_uri":"http://rubygems.org/gems/zombie-chaser", "authors":"Andrew Grimm, Ryan Davis, Eric Hodel, Kevin Clark"}]}
  	expected_name = "zombie-chaser"
	  expected_downloads = 170
  	assert_name_and_downloads_are expected_name, expected_downloads, json_text, "Can't parse JSON"
  end

  def test_median_reporting
    older_data_set = {"zombie-chaser" => 170, "activesupport" => 413643, "beekeeper-pro-ruby" => 272}
    newer_data_set = {"zombie-chaser" => 172, "activesupport" => 532638, "beekeeper-pro-ruby" => 273}
    percentile = 50
    expected_increase = 2
    assert_increase_is expected_increase, older_data_set, newer_data_set, percentile, "Can't determine median increase"
  end

  def test_90th_percentile
    older_data_set = {"a" => 10, "b" => 500, "c" => 40, "d" => 60, "e" => 30, "f" => 60, "g" => 20, "h" => 5000, "i" => 600, "j" => 700, "k" => 800}
    newer_data_set = {"a" => 15, "b" => 501, "c" => 47, "d" => 68, "e" => 39, "f" => 62, "g" => 29, "h" => 5005, "i" => 606, "j" => 707, "k" => 808}
    percentile = 90
    expected_increase = 2 # f increasing by 2, not b increasing by 1
    assert_increase_is expected_increase, older_data_set, newer_data_set, percentile, "Can't determine 90th centile increase"
  end

end
