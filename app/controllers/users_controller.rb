require 'eventful/api'

class UsersController < ApplicationController
    def update
        user = current_user

        user.city = params[:user][:city]
        user.state = params[:user][:state]

        user.save

        # raise params.to_yaml
        redirect_to :root
    end

    def eventful
        timeframe = params[:timeframe]

        # timeframe must be in the form 'YYYYMMDD00-YYYYMMDD00'
        # timeframe = "2013111000-2013111100"
        eventful = Eventful::API.new ENV['eventful_key']

        @events = eventful.call 'events/search',
            date: timeframe, location: current_user.city

        # raise .to_yaml
        
    end 
end