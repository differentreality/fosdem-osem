# frozen_string_literal: true

module Admin
  class SponsorShipmentsController < Admin::BaseController
    load_and_authorize_resource
    load_and_authorize_resource :sponsor
    load_and_authorize_resource :conference, find_by: :short_title

    def index
    end

    def new
      @sponsor_shipment = @sponsor.sponsor_shipments.new
      @url = admin_conference_sponsor_sponsor_shipments_path(@conference, @sponsor)
      # @sponsor_shipment = @sponsor_swag.sponsor_shipments.new(sponsor: @sponsor)
    end

    def show
    end

    def edit
      @url = admin_conference_sponsor_sponsor_shipment_path(@conference, @sponsor, @sponsor_shipment)
    end

    def create
      @sponsor_shipment = @sponsor.sponsor_shipments.new(sponsor_shipment_params)
      # @sponsor_shipment = @sponsor_swag.sponsor_shipments.new(sponsor_shipment_params)
      # @sponsor_shipment.sponsor = @sponsor
      # @sponsor_swag.sponsor_shipments << @sponsor_shipment

      if @sponsor_shipment.save
        flash[:notice] = 'Successfully saved shipment.'
        redirect_to admin_conference_sponsor_sponsor_shipments_path(@conference, @sponsor)
      else
        @url = admin_conference_sponsor_sponsor_shipments_path(@conference, @sponsor)
        flash[:error] = 'Could not save shipment. ' + @sponsor_shipment.errors.full_messages.to_sentence
        render :new
      end
    end

    def update
      if @sponsor_shipment.update_attributes(sponsor_shipment_params)
        flash[:notice] = 'Successfully updated shipment information.'
      else
        flash[:error] = 'Could not update shipment information.'
      end

      redirect_to admin_conference_sponsors_path(@conference)
    end

    def destroy
    end

    private

    def sponsor_swag_params
      params.require(:sponsor_swag).permit(:name, :quantity, :notes)
    end

    def sponsor_shipment_params
      params.require(:sponsor_shipment).permit(:carrier, :track_no, :boxes,
                                               :delivered, :available,
                                               :dispatched_at,
                                               sponsor_swag_ids: [])
    end
  end
end
