require 'uri'
require 'open-uri'
require 'json'
require 'cinch'
require 'cvbot/api'

module CvBot
  class Client
    include Cinch::Plugin
    MAX_DISPLAY = 10

    set :required_options, [:apihost, :encoder]

    match /cv (.+)/, group: :blegh, method: :handle_message, react_on: :channel

    def handle_message(m, arg)
      @encoder = config[:encoder] if @encoder == nil
      @api     = Api.new(config[:apihost]) if @api == nil
      word     = @encoder.decode(arg)
      word.chomp!
      word.gsub!(/\s+/, '')
      target   = m.target

      if /rank/ =~ word
        handle_rank(target, word)
      else
        handle_search(target, word)
      end
    end

    def handle_search(target, word)
      type, match_words, list = @api.search(word)

      if list != nil && list.size > 0
        target.notice "-> #{ @encoder.encode(match_words.join(" / ")) }"
        list.take(MAX_DISPLAY).each do |description|
          target.notice @encoder.encode(description)
        end
        if list.size > MAX_DISPLAY
          target.notice "... #{list.size} characters"
        end
      end
    end

    def handle_rank(target, word)
      list = @api.rank(word)
      if list != nil && list.size > 0
        list.take(MAX_DISPLAY).each do |description|
          target.notice @encoder.encode(description)
        end
        if list.size > MAX_DISPLAY
          target.notice "... #{list.size} ranks"
        end
      end
    end
  end
end
