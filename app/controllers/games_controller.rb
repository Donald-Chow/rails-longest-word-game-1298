require 'rest-client'
require 'json'

class GamesController < ApplicationController
  def new
    session[:score] = 0 if session[:score].nil?

    @letters = []
    10.times { @letters << ('A'..'Z').to_a.sample }
    @current_score = session[:score]
  end

  def score
    @letters = params['letters'].split(',')
    @input = params['input'].upcase
    @result = check(@letters, @input)
    @current_score = session[:score]
  end

  def reset
    session[:score] = 0
    redirect_to new_path
  end

  private

  def check(letters, input)
    english = checkEnglish(input)
    valid = checkValid(letters, input)
    if english && valid
      session[:score] += 3
      "<strong>Congratulations!</strong> #{input} is a valid English word! + 3 points"
    elsif english
      session[:score] += 1
      "Sorry but <strong>#{input}</strong> can't be build out of #{letters.join(", ")}. + 1 points"
    else
      "Sorry but <strong>#{input}</strong> does not seem to be a valid English word... no points"
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
