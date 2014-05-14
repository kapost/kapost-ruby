module Kapost
  class Client

    include Content
    include ContentType
    include CustomFields

    RESPONSE_SUCCESS = :success
    RESPONSE_FAILURE = :failure

    attr_accessor *Configuration::VALID_PARAMS

    # Create a new instance of Kapost::Client
    #
    # @param [Hash] options Options to configure the client
    #
    # @example
    #   client = Kapost::Client.new(:api_key => ENV['KAPOST_API_KEY'], :instance => ENV['KAPOST_INSTANCE'])
    #
    # @raise [ArgumentError] when required options are not set
    # @return [Object]
    def initialize(options = {})
      config = Kapost.options.merge(options)

      Configuration::REQUIRED_PARAMS.map do |param|
        raise ArgumentError, "Required parameter: #{param} is not set" if config[param].nil?
      end

      Configuration::VALID_PARAMS.each do |key|
        Kapost.send("#{key}=", config[key])
      end

      fqdn = [Kapost.instance, Kapost.domain].join('.')
      url  = ["#{Kapost.protocol}://#{fqdn}", Kapost.api_path, Kapost.api_version].join('/')

      @client = ::RestClient::Resource.new(url, :user => Kapost.api_token, :password => nil, :user_agent => Kapost.user_agent)
    end

    protected
    # Creates a piece of content
    #
    # @param [Hash] params Parameters
    def create_action(path, params)
      post(path, params) if valid_params(path, params)
    end

    # Lists content
    #
    # @param [Hash] params Parameters
    def list_action(path, params)
      get(path, params) if valid_params(path, params)
    end

    # Shows a piece of content
    #
    # @param [Hash] params Parameters
    def show_action(path, params)
      get(set_path(path, params[:id]), params) if valid_params(path, params)
    end

    # Updates a piece of content
    #
    # @param [Hash] params Parameters
    def update_action(path, params)
      put(set_path(path, params[:id]), params) if valid_params(path, params)
    end

    # Deletes a piece of content
    #
    # @param [Hash] params Parameters
    def delete_action(path, params)
      delete(set_path(path, params[:id]), params) if valid_params(path, params)
    end

    private

    # Sets a the path to a specific piece of content
    #
    # @param [String] id ID or slug of the content
    # @return [String] Content path
    def set_path(path, id)
      [path, id].join('/')
    end

    def action_params(path)
      if respond_to? "#{path}_params"
        send("#{path}_params")
      else
        {}
      end
    end

    # Validates correct parameters are being used
    #
    # @private
    # @param [Hash] params Hash of parameters
    # @return [true|false]
    def valid_params(path, params)
      keys = params.keys

      # Is this anywhere near a good idea or am I being too cute here?
      operation = caller[0][/`([^']*)'/, 1]
      action = operation.split('_', 2).first

      params = action_params(path)

      if params.has_key? action
        return keys - params[action] === []
      end

      # if we haven't defined valid params for the perticular action then allow everything
      return true
    end

    # Performs an HTTP GET operation
    #
    # @private
    # @param [String] path The path to the resource
    # @param [Hash] params Parameters to be sent with the request
    # @return [Hash] response body
    def get(path, params)
      request(:get, path, :params => params)
    end

    # Performs an HTTP POST operation
    #
    # @private
    # @param [String] path The path to the resource
    # @param [Hash] params Parameters to be sent with the request
    # @return [Hash] response body
    def post(path, params)
      request(:post, path, params)
    end

    # Performs an HTTP PUT operation
    #
    # @private
    # @param [String] path The path to the resource
    # @param [Hash] params Parameters to be sent with the request
    # @return [Hash] response body
    def put(path, params)
      request(:put, path, params)
    end

    # Performs an HTTP DELETE operation
    #
    # @private
    # @param [String] path The path to the resource
    # @param [Hash] params Parameters to be sent with the request
    # @return [Boolean]
    def delete(path, params)
      request(:delete, path, :params => params)
    end

    def request(method, path, params)
      begin
      parse_response @client[path].send(method, params) { |response, request, result|
        response
      }
      rescue RestClient::RequestTimeout => ex
        Kapost::Result.new(500, ex.message)
      end
    end

    # Validates the response & raises any errors encountered
    #
    # @private
    # @param [Object] response The response object
    # @return [Hash] The response body
    # @raise [KapostError]
    def parse_response(response)
      json_response = nil

      begin
        json_response = JSON.parse(response, :symbolize_names => true)
      rescue Exception => ex
        logger.info response
        logger.error ex.message
      end

      data = nil
      case response.code
      # Successful get/create/update
      when 200..201
        data = json_response[:response]
      # Successful delete
      when 204
        true
      when 300..399
        data = 'Unauthorized redirect'
      when 400..503
        data = json_response
      else
        raise 'Response was not understood'
      end

      Kapost::Result.new(response.code, data)
    end

    def logger
      Kapost.logger
    end
  end
end
