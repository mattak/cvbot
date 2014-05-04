require 'uri'
require 'open-uri'
require 'json'
require 'cinch'

module CvBot
  class Client
    include Cinch::Plugin
    MAX_DISPLAY = 10

    set :required_options, [:apihost, :encoder]

    match /cv (.+)/, group: :blegh, method: :handle_message, react_on: :channel

    def is_json?(str)
      return false if str == nil

      begin
        return !!JSON.parse(str)
      rescue
        return false
      end
    end

    def getlist(apihost, word)
      puts `echo #{ word } | nkf --guess`
      debug word
      word_escape = URI.escape(word)

      if apihost == nil
        return []
      end

      url = "#{ apihost }/search/actor/#{ word_escape }.json"

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

    def handle_message(m, arg)
      encoder = config[:encoder]
      apihost = config[:apihost]
      word    = encoder.decode(arg)
      word.chomp!
      word.gsub!(/\s+/, '')
      target  = m.target

      list = getlist(apihost, word)
      if list != nil && list.size > 0
        list.take(MAX_DISPLAY).each do |description|
          target.notice encoder.encode(description)
        end
        if list.size > MAX_DISPLAY
          target.notice "... #{list.size} characters"
        end
      end
    end
  end
end
