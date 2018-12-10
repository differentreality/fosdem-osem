# frozen_string_literal: true

module Admin
  class SponsorsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :sponsor, through: :conference
    before_action :sponsorship_level_required, only: [:index, :new]

    def index
      authorize! :index, Sponsor.new(conference_id: @conference.id)
      @sponsors_contacted = { to_contact: @conference.sponsors.to_contact.count, contacted: @conference.sponsors.contacted.count, in_negotiations: @conference.sponsors.unconfirmed.count }
    end

    def edit; end

    def new
      @sponsor = @conference.sponsors.new
    end

    def create
      @sponsor = @conference.sponsors.new(sponsor_params)
      if @sponsor.save
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title),
                    notice: 'Sponsor successfully created.'
      else
        flash.now[:error] = "Creating sponsor failed: #{@sponsor.errors.full_messages.join('. ')}."
        render :new
      end
    end

    def update
      if @sponsor.update_attributes(sponsor_params)
        respond_to do |format|
          format.html {
            redirect_to admin_conference_sponsors_path(
                        conference_id: @conference.short_title),
                        notice: 'Sponsor successfully updated.'
          }
          format.js { head :ok }
        end
      else
        flash.now[:error] = "Update sponsor failed: #{@sponsor.errors.full_messages.join('. ')}."
        render :edit
      end
    end

    def destroy
      if @sponsor.destroy
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title),
                    notice: 'Sponsor successfully deleted.'
      else
        redirect_to admin_conference_sponsors_path(conference_id: @conference.short_title),
                    error: 'Deleting sponsor failed! ' \
                    "#{@sponsor.errors.full_messages.join('. ')}."
      end
    end

    def prepare_email
      @sponsor_email = SponsorEmail.new(from: ENV['SPONSORS_EMAIL_FROM'], to: @sponsor.email)
    end

    def email
      # Send email to sponsor
      begin
        SponsorEmailJob.perform_later(@sponsor, @conference, params[:sponsor_email][:from], params[:sponsor_email][:subject], params[:sponsor_email][:body])
        flash[:notice] = "Email sent to #{@sponsor.name}(#{@sponsor.email})"
      rescue => error
        flash[:error] = 'Email failed' + e.message
      end

      redirect_to admin_conference_sponsors_path(@conference)
    end

    def confirm
      @sponsor.confirm!

      if @sponsor.save
        redirect_to admin_conference_sponsors_path(@conference.short_title),
                      notice: 'Sponsor successfully confirmed!'
      else
        flash[:error] = 'Sponsor couldn\' t be confirmed.'
        redirect_to admin_conference_sponsors_path(@conference.short_title)
      end
    end

    def cancel
      @sponsor.cancel!

      if @sponsor.save
        redirect_to admin_conference_sponsors_path(@conference.short_title),
                      notice: 'Sponsor successfully canceled'
      else
        flash[:error] = 'Sponsor couldn\'t be canceled'
        redirect_to admin_conference_sponsors_path(@conference.short_title)
      end
    end

    def contacted
      @sponsor.contacted!

      if @sponsor.save
        redirect_to admin_conference_sponsors_path(@conference.short_title),
                      notice: 'Sponsor successfully contacted'
      else
        flash[:error] = "Sponsor stated couldn't be updated to 'contacted'"
        redirect_to admin_conference_sponsors_path(@conference.short_title)
      end
    end

    def unconfirmed
      @sponsor.unconfirmed!

      if @sponsor.save
        redirect_to admin_conference_sponsors_path(@conference.short_title),
                      notice: 'Sponsor state successfully changed to unconfirmed.'
      else
        flash[:error] = "Sponsor stated couldn't be updated to 'unconfirmed'"
        redirect_to admin_conference_sponsors_path(@conference.short_title)
      end
    end

    def remove_field
      respond_to do |format|
        format.js
      end
    end

    private

    def sponsor_params
      params.require(:sponsor).permit(:name, :description, :website_url,
                                      :picture, :picture_cache,
                                      :sponsorship_level_id,
                                      :conference_id,
                                      :has_swag, :has_banner, :email,
                                      :state, :paid, :amount,
                                      :invoice_name, :invoice_address, :invoice_vat,
                                      sponsor_swags_attributes: [:name, :quantity, :id, :_destroy],
                                      sponsor_shipments_attributes: [:carrier, :track_no, :boxes, :id, :_destroy, sponsor_swag_ids: []] )
    end

    def shipment_params
      params.require(:sponsor).require(:shipment).permit([:carrier,
                                                          :track_no,
                                                          :boxes,
                                                          :swag])
    end

    def sponsorship_level_required
      return unless @conference.sponsorship_levels.empty?
      redirect_to admin_conference_sponsorship_levels_path(conference_id: @conference.short_title),
                  alert: 'You need to create atleast one sponsorship level to add a sponsor'
    end
  end
end
