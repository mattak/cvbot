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

      list = @api.search(word)
      if list != nil && list.size > 0
        list.take(MAX_DISPLAY).each do |description|
          target.notice @encoder.encode(description)
        end
        if list.size > MAX_DISPLAY
          target.notice "... #{list.size} characters"
        end
      end
    end
  end
end
