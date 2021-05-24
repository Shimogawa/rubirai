# frozen_string_literal: true

module Rubirai
  class Bot
    # Start authentication. Will store the session.
    # @param auth_key [String] the auth key defined in config file
    # @return [String] the session key which will also be stored in the bot
    def auth(auth_key)
      v = call :post, '/auth', json: { "authKey": auth_key }
      @session = v['session']
    end

    # Verify and start a session. Also bind the session to a bot with the qq id.
    # @param qq [String, Integer] qq id
    # @param session [String, nil] the session key. Set to `nil` will use the saved credentials.
    # @return [nil]
    def verify(qq, session = nil)
      check qq, session

      call :post, '/verify', json: { "sessionKey": @session || session, "qq": qq.to_i }
      @session = session if session
      @qq = qq
      nil
    end

    # Release a session.
    # Only fill in the arguments when you want to control another bot on the same Mirai process.
    # @param qq [String, Integer, nil] qq id. Set to `nil` will use the logged in bot id.
    # @param session [String, nil] the session key. Set to `nil` will use the logged in credentials.
    # @return [nil]
    def release(qq = nil, session = nil)
      qq ||= @qq
      raise RubiraiError, "not same qq: #{qq} and #{@qq}" if qq != @qq
      check qq, session

      call :post, '/release', json: { "sessionKey": @session || session, "qq": qq.to_i }
      @session = nil
      @qq = nil
      nil
    end

    # Log you in.
    #
    # @param qq [String, Integer] qq id
    # @param auth_key [String] the auth key set in the settings file for mirai-api-http.
    # @return [nil]
    # @see #auth
    # @see #verify
    def login(qq, auth_key)
      auth auth_key
      verify qq
    end

    alias connect login

    # Log you out.
    #
    # @return [nil]
    # @see #release
    def logout
      release
    end

    alias disconnect logout

    private

    def check(qq, session = nil)
      raise RubiraiError, 'Wrong format for qq' unless qq.to_i.to_s == qq.to_s
      raise RubiraiError, 'No session provided' unless @session || session
    end
  end
end
