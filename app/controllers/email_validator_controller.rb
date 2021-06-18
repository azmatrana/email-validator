class EmailValidatorController < ApplicationController
  before_action :load_results

  def index
    @search_object = EmailFinder::Email.new
  end

  def search
    @search_object = EmailFinder::Email.new(search_params)
    puts @search_object.valid?
    if @search_object.valid?
      if fetch_email = @search_object.search
        EmailRecord.create(email: fetch_email)
        flash.now[:notice] = "Successfully found an email record."
      else
        flash.now[:alert] = "No records found."
      end
    else
      flash.now[:alert] = "Search form is not valid."
    end
    render :index
  end

  private

  def search_params
    params.require(:email_finder_email).permit(:first_name, :last_name, :url)
  end

  def load_results
    @results = EmailRecord.all
  end

end
