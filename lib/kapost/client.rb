module Kapost
  class Client

    include Content
    include Newsroom

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
      url  = ["https://#{fqdn}", Kapost.api_path, Kapost.api_version].join('/')

      @client = ::RestClient::Resource.new(url, :user => Kapost.api_token, :password => nil, :user_agent => Kapost.user_agent)
    end

    private

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
      parse_response @client[path].send(method, params) { |response, request, result|
        response
      }
    end

    # Validates the response & raises any errors encountered
    #
    # @private
    # @param [Object] response The response object
    # @return [Hash] The response body
    # @raise [KapostError]
    def parse_response(response)
      json_response = JSON.parse(response, :symbolize_names => true)

      data = nil
      case response.code
      # Successful get/create/update
      when 200..201
        data = json_response[:response]
      # Successful delete
      when 204
        true
      when 400..503
        data = json_response
      else
        raise 'Response was not understood'
      end

      Kapost::Result.new(response.code, data)
    end
  end
end
