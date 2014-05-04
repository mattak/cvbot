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

    def access_api(url)
      begin
        debug(url)
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

      return json
    end

    def search_actor(word_escape)
      url  = "#{ @apihost }/search/actor/#{ word_escape }.json"
      json = access_api(url)

      return if json == []

      result_list = []
      actor = json[0]
      actor['programs'].each_with_index do |program, index|
        character = actor['characters'][index]
        result_list.push("#{ program['title'] } / #{ character['name'] }")
      end

      return result_list
    end

    def search_program(word_escape)
      url  = "#{ @apihost }/search/program/#{ word_escape }.json"
      json = access_api(url)
      
      return if json == []

      result_list = []
      program = json[0]
      program['characters'].each_with_index do |character, index|
        result_list.push "#{ character['actor']['name'] } / #{ character['name'] }"
      end

      return result_list
    end


    def search(word)
      puts `echo #{ word } | nkf --guess`
      debug word
      word_escape = URI.escape(word)

      if @apihost == nil
        return []
      end

      actor_result = search_actor(word_escape)
      return actor_result if actor_result != nil && actor_result.size > 0

      program_result = search_program(word_escape)
      return program_result if program_result != nil && program_result.size > 0

    end
  end
end
