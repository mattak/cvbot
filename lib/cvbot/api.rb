require 'json'
require 'uri'
require 'set'

module CvBot
  class Api
    MAX_RANK_PROGRAMS = 3

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
      names = Set.new([actor['name']])
      actor['programs'].each_with_index do |program, index|
        character = actor['characters'][index]
        result_list.push("#{ program['title'] } / #{ character['name'] }")
      end

      return [names.to_a, result_list]
    end

    def search_program(word_escape)
      url  = "#{ @apihost }/search/program/#{ word_escape }.json"
      json = access_api(url)

      return if json == []

      result_list = []
      program = json[0]
      titles = Set.new([program['title']])
      program['characters'].each_with_index do |character, index|
        result_list.push "#{ character['name'] } / #{ character['actor']['name'] }"
      end

      return [titles.to_a, result_list]
    end

    def search_character(word_escape)
      url = "#{ @apihost }/search/character/#{ word_escape }.json"
      json = access_api(url)

      return if json == []

      result_list = []
      names = Set.new
      json.each do |character|
        names.add(character['name'])
        result_list.push "#{ character['program']['title'] } / #{ character['actor']['name'] }"
      end

      return [names.to_a, result_list]
    end

    def escape(word)
      return URI.escape(word).gsub('?', '%3F').gsub('&', '%26')
    end

    def search(word)
      debug word
      word_escape = escape(word)

      if @apihost == nil
        return []
      end

      match_words, actor_result = search_actor(word_escape)
      debug "actor_result #{} "
      return [:actor, match_words, actor_result] if actor_result != nil && actor_result.size > 0

      match_words, program_result = search_program(word_escape)
      return [:program, match_words, program_result] if program_result != nil && program_result.size > 0

      match_words, character_result = search_character(word_escape)
      return [:character, match_words, character_result] if character_result != nil && character_result.size > 0

      return []
    end

    def rank(word)
      word_escape = escape(word)

      if @apihost == nil
        return []
      end

      json = access_api("#{ @apihost }/rank/actor.json")
      return if json == []

      result_list = []
      json.each_with_index do |rank|
        programs = []
        programs = rank['actor']['programs'].take(MAX_RANK_PROGRAMS).collect {|program| program['title'] }.push('...').join(' / ')
        result_list.push("#{ rank['count'] }: #{ rank['actor']['name'] } (#{ programs })")
      end

      return result_list
    end
  end
end
