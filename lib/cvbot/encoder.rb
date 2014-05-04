module CvBot
  class Encoder
    def initialize(enable_jis=true)
      @enable_jis = enable_jis
    end

    def decode(word)
      if @enable_jis
        return word.force_encoding('ISO-2022-JP').encode('UTF-8')
      end
      return word
    end

    def encode(word)
      if @enable_jis
        return `echo #{word} | nkf -j`.chomp
      end
      return word
    end
  end
end
