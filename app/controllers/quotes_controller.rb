require 'net/http'
require 'json'

class QuotesController < ApplicationController
  def index
    @quote = Quote.order("RANDOM()").first
    # Calling for a new quote from forismatic.com every page load
    # call_api
  end

  def create
    @quote = Quote.create(quote_params)
    if @quote.invalid?
      flash[:error] = '<strong>Could not save,</strong> the data you entered is invalid.'
    end
    redirect_to root_path
  end

  def call_api
    uri = URI('http://api.forismatic.com/api/1.0/')
    params = {method: 'getQuote', lang: 'en', format: 'json'}
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    if res.body
      json_response = JSON.parse(res.body)
      $author = json_response['quoteAuthor']
      $quote = json_response['quoteText']
    end
    if $author == ""
      $author = "Unknown"
    end

    @quote = Quote.create(saying: $quote, author: $author)
    @link = json_response['quoteLink']
  end

  private
  def quote_params
    params.require(:quote).permit(:saying, :author)
  end

  def about
  end
end





