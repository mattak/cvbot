require 'helper'
require 'cvbot/encoder'

class CvBotEncoderTest < TestCase
  def setup
  end

  test "can encode" do
    @encoder = CvBot::Encoder.new(true)
    assert_equal @encoder.encode('日本語'), `echo '日本語' | nkf -j`.chomp
  end

  test "can decode" do
    @encoder = CvBot::Encoder.new(true)
    word_jis = `echo '日本語' | nkf -j`.chomp
    assert_equal '日本語', @encoder.decode(word_jis)
  end
end
