require 'rest-client'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = []
    10.times { @letters << ('A'..'Z').to_a.sample }
  end

  def score
    @letters = params['letters'].split(',')
    @input = params['input'].upcase
    @result = check(@letters, @input)
  end

  private

  def check(letters, input)
    english = checkEnglish(input)
    valid = checkValid(letters, input)

    if english && valid
      "<strong>Congratulations!</strong> #{input} is a valid English word"
    elsif english
      "Sorry but <strong>#{input}</strong> can't be build out of #{letters.join(", ")}"
    else
      "Sorry but <strong>#{input}</strong> does not seem to be a valid English word..."
    end
  end

  def checkEnglish(input)
    response = RestClient.get("https://wagon-dictionary.herokuapp.com/#{input}")
    data = JSON.parse(response.body)
    data['found']
  end

  def checkValid(letters, input)
    input.chars.all? do |letter|
      input.count(letter) <= letters.count(letter)
    end
  end
end
