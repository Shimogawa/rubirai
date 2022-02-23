# frozen_string_literal: true

module Rubirai
  class Bot
    # Start verification. Will store the session.
    # @param verify_key [String] the auth key defined in config file
    # @return [String] the session key which will also be stored in the bot
    def verify(verify_key)
      v = call :post, '/verify', json: { "verifyKey": verify_key }
      @session = v['session']
    end

    # Verify and start a session. Also bind the session to a bot with the qq id.
    # @param qq [String, Integer] qq id
    # @param session [String, nil] the session key. Set to `nil` will use the saved credentials.
    # @return [void]
    def bind(qq, session = nil)
      check qq, session

      call :post, '/bind', json: { "sessionKey": @session || session, "qq": qq.to_i }
      @session ||= session
      @qq = qq
      nil
    end

    # Release a session.
    # Only fill in the arguments when you want to control another bot on the same Mirai process.
    # @param qq [String, Integer, nil] qq id. Set to `nil` will use the logged in bot id.
    # @param session [String, nil] the session key. Set to `nil` will use the logged in credentials.
    # @return [void]
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
    # @param verify_key [String] the auth key set in the settings file for mirai-api-http.
    # @param single_mode [Boolean] if to skip binding (need to enable `singeMode` for
    #                              mirai-http-api)
    # @return [void]
    # @see #bind
    # @see #verify
    def login(qq, verify_key, single_mode: false)
      verify verify_key
      single_mode or bind(qq)
      nil
    end

    alias connect login

    # Log you out.
    #
    # @return [void]
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
