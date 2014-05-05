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
      File.open("tmp.log", "a+") do |line|
        line.write "#{message}\n"
      end
    end

    def access_api(url)
      begin
        debug(url)
        json_str = open(url) do |f|
          charset = f.charset
          f.read
        end
      rescue
        debug "request failed : #{ url }"
        return []
      end

      debug json_str
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

      return [actor['name'], result_list]
    end

    def search_program(word_escape)
      url  = "#{ @apihost }/search/program/#{ word_escape }.json"
      json = access_api(url)

      return if json == []

      result_list = []
      program = json[0]
      program['characters'].each_with_index do |character, index|
        result_list.push "#{ character['name'] } / #{ character['actor']['name'] }"
      end

      return [program['title'], result_list]
    end

    def search_character(word_escape)
      url = "#{ @apihost }/search/character/#{ word_escape }.json"
      json = access_api(url)
      debug "character json : #{json}"

      return if json == []

      result_list = []
      character    = json[0]
      result_list.push "#{ character['program']['title'] } / #{ character['actor']['name'] }"

      return [character['name'], result_list]
    end

    def search(word)
      puts `echo #{ word } | nkf --guess`
      debug word
      word_escape = URI.escape(word)

      if @apihost == nil
        return []
      end

      match_word, actor_result = search_actor(word_escape)
      debug "actor_result #{} "
      return [:actor, match_word, actor_result] if actor_result != nil && actor_result.size > 0

      match_word, program_result = search_program(word_escape)
      return [:program, match_word, program_result] if program_result != nil && program_result.size > 0

      match_word, character_result = search_character(word_escape)
      return [:character, match_word, character_result] if character_result != nil && character_result.size > 0

      return []
    end
  end
end
