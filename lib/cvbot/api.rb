require 'json'
require 'uri'

module CvBot
  class Api
    def initialize(apihost)
      @apihost = apihost
    end

    def is_json?(str)
      return false if str == nil

      begin
        return !!JSON.parse(str)
      rescue
        return false
      end
    end

    def debug(message)
      puts message
    end

    def getlist(word)
      puts `echo #{ word } | nkf --guess`
      debug word
      word_escape = URI.escape(word)

      if @apihost == nil
        return []
      end

      url = "#{ @apihost }/search/actor/#{ word_escape }.json"

      begin
        json_str = open(url) do |f|
          charset = f.charset
          f.read
        end
      rescue
        log "request failed : #{ url }"
        return []
      end

      puts json_str
      return [] if !is_json?(json_str)

      json = JSON.parse(json_str)
      return [] if json.size < 1

      result_list = []
      actor = json[0]
      actor['programs'].each_with_index do |program, index|
        character = actor['characters'][index]
        result_list.push("#{ program['title'] } / #{ character['name'] }")
      end

      return result_list
    end
  end
end
