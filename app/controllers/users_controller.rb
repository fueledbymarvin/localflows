class UsersController < ApplicationController
    before_filter :authenticated, except: [:new]

    def new
        redirect_to "/auth/google?origin=#{params[:city]},#{params[:state]}"
    end

    def index
      @users = User.all
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @users }
        format.json  { render :json => @users.map(&:attributes) }
      end
    end

    def update
        user = current_user

        user.city = params[:user][:city]
        user.state = params[:user][:state]

        user.save

        redirect_to :root
    end

    def eventful
        timeframe = params[:timeframe][:start].delete('-') +
                    '00-' + params[:timeframe][:end].delete('-') + '00'
        emails = params[:search][:users].scan(/\((.+?)\)/).collect {|x| x[0] }
        @nFriends = emails.length + 1

        events = current_user.eventful.call('events/search', {
            date: timeframe,
            location: "#{current_user.city}, #{current_user.state}",
            page_size: 100,
            sort_order: "popularity",
            keywords: params[:search][:keyword]
        })["events"]

        if(events.nil?)
            @events = nil
        else
            @events = current_user.group(Date.parse(params[:timeframe][:start]), Date.parse(params[:timeframe][:end]), emails, events["event"])
        end
    end
end