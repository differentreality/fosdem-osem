# frozen_string_literal: true

module Admin
  class SponsorSwagsController < Admin::BaseController
    load_and_authorize_resource
    load_and_authorize_resource :sponsor
    load_and_authorize_resource :conference, find_by: :short_title

    def index
    end

    def new
      @sponsor_swag = @sponsor.sponsor_swags.new
      @url = admin_conference_sponsor_sponsor_swags_path(@conference, @sponsor)
      @sponsor_shipment = @sponsor_swag.sponsor_shipments.new(sponsor: @sponsor)
    end

    def show
    end

    def edit
      @url = admin_conference_sponsor_sponsor_swag_path(@conference, @sponsor, @sponsor_swag)
    end

    def create
      @sponsor_swag = @sponsor.sponsor_swags.new(sponsor_swag_params)

      if params[:sponsor_shipment]
        @sponsor_shipment = @sponsor_swag.sponsor_shipments.new(sponsor_shipment_params)
        @sponsor_shipment.sponsor = @sponsor
        @sponsor_swag.sponsor_shipments << @sponsor_shipment
      end

      if @sponsor_swag.save
        flash[:notice] = 'Successfully saved swag.'
        redirect_to admin_conference_sponsor_sponsor_swags_path(@conference, @sponsor)
      else
        @url = admin_conference_sponsor_sponsor_swags_path(@conference, @sponsor)
        flash[:error] = 'Could not save swag. ' + @sponsor_swag.errors.full_messages.to_sentence
        render :new
      end
    end

    def update
    end

    def destroy
    end

    private

    def sponsor_swag_params
      params.require(:sponsor_swag).permit(:name, :quantity, :notes)
    end

    def sponsor_shipment_params
      params.fetch(:sponsor_shipment).permit!(:carrier, :track_no, :boxes, :delivered, :available, :dispatched_at)
    end
  end
end
