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

    def current_emails
        @emails = params[:search][:users].scan(/\((.+?)\)/).collect {|x| x[0] }
    end

    def eventful
        timeframe = params[:timeframe][:start].delete('-') +
                    '00-' + params[:timeframe][:end].delete('-') + '00'

        # emails = params[:search][:users].scan(/\((.+?)\)/).collect {|x| x[0] }

        @nFriends = current_emails.length + 1

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
            @events = current_user.group(Date.parse(params[:timeframe][:start]), Date.parse(params[:timeframe][:end]), current_emails, events["event"])
        end
    end

    def invite
        confirm_event(params[:emails])
        redirect_to :root, notice: "Invitations successfully sent!"
    end

    ## this action will send an email through event_confirmation mailer
    ## it will be linked to from the page listing search results
    def confirm_event(current_emails)
        current_emails.each do |email|
            # raise
            UserMailer.event_confirmation(current_user, params["event-title"], params["event-description"], email).deliver

        end
    end
end