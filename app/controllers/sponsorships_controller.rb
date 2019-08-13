# frozen_string_literal: true

class SponsorshipsController < ApplicationController
  load_and_authorize_resource :conference, find_by: :short_title
  load_and_authorize_resource :sponsorship, through: :conference

  def index
    authorize! :index, Sponsorship.new(conference_id: @conference.id)
    @sponsorships_contacted = { to_contact: @conference.sponsorships.to_contact.count, contacted: @conference.sponsorships.contacted.count, in_negotiations: @conference.sponsorships.unconfirmed.count }
  end

  def edit; end

  def new
    @sponsor = Sponsor.new
    @sponsorship = @conference.sponsorships.new(submitter: current_user)
  end

  def create
    @sponsorship = @conference.sponsorships.new(sponsorship_params)
    if @sponsorship.save
      redirect_to conference_sponsorships_path(conference_id: @conference.short_title),
                  notice: 'Sponsorship successfully created.'
    else
      flash.now[:error] = "Creating sponsorship failed: #{@sponsorship.errors.full_messages.join('. ')}."
      render :new
    end
  end

  def update
    if @sponsorship.update_attributes(sponsorship_params)
      respond_to do |format|
        format.html {
          redirect_to conference_sponsorships_path(
                      conference_id: @conference.short_title),
                      notice: 'Sponsorship successfully updated.'
        }
        format.js { head :ok }
      end
    else
      flash.now[:error] = "Update sponsorship failed: #{@sponsorship.errors.full_messages.join('. ')}."
      render :edit
    end
  end

  def destroy
    if @sponsorship.destroy
      redirect_to conference_sponsorships_path(conference_id: @conference.short_title),
                  notice: 'Sponsorship successfully deleted.'
    else
      redirect_to conference_sponsorships_path(conference_id: @conference.short_title),
                  error: 'Deleting sponsorship failed! ' \
                  "#{@sponsorship.errors.full_messages.join('. ')}."
    end
  end

  def prepare_email
    @sponsorship_email = SponsorshipEmail.new(from: ENV['SponsorshipS_EMAIL_FROM'], to: @sponsorship.email)
  end

  def email
    # Send email to sponsorship
    begin
      SponsorshipEmailJob.perform_later(@sponsorship, @conference, params[:sponsorship_email][:from], params[:sponsorship_email][:subject], params[:sponsorship_email][:body])
      flash[:notice] = "Email sent to #{@sponsorship.name}(#{@sponsorship.email})"
    rescue => error
      flash[:error] = 'Email failed' + e.message
    end

    redirect_to conference_sponsorships_path(@conference)
  end

  def confirm
    @sponsorship.confirm!

    if @sponsorship.save
      redirect_to conference_sponsorships_path(@conference.short_title),
                    notice: 'Sponsorship successfully confirmed!'
    else
      flash[:error] = 'Sponsorship couldn\' t be confirmed.'
      redirect_to conference_sponsorships_path(@conference.short_title)
    end
  end

  def cancel
    @sponsorship.cancel!

    if @sponsorship.save
      redirect_to conference_sponsorships_path(@conference.short_title),
                    notice: 'Sponsorship successfully canceled'
    else
      flash[:error] = 'Sponsorship couldn\'t be canceled'
      redirect_to conference_sponsorships_path(@conference.short_title)
    end
  end

  def contacted
    @sponsorship.contacted!

    if @sponsorship.save
      redirect_to conference_sponsorships_path(@conference.short_title),
                    notice: 'Sponsorship successfully contacted'
    else
      flash[:error] = "Sponsorship stated couldn't be updated to 'contacted'"
      redirect_to conference_sponsorships_path(@conference.short_title)
    end
  end

  def unconfirmed
    @sponsorship.unconfirmed!

    if @sponsorship.save
      redirect_to conference_sponsorships_path(@conference.short_title),
                    notice: 'Sponsorship state successfully changed to unconfirmed.'
    else
      flash[:error] = "Sponsorship stated couldn't be updated to 'unconfirmed'"
      redirect_to conference_sponsorships_path(@conference.short_title)
    end
  end

  def remove_field
    respond_to do |format|
      format.js
    end
  end

  private

  def sponsorship_params
    params.require(:sponsorship).permit(:name, :description, :website_url,
                                    :picture, :picture_cache,
                                    :sponsorship_level_id,
                                    :conference_id,
                                    :has_swag, :has_banner, :email,
                                    :state, :paid, :amount,
                                    :invoice_name, :invoice_address, :invoice_vat,
                                    sponsorship_swags_attributes: [:name,
                                                               :quantity,
                                                               :id,
                                                               :_destroy],
                                    sponsorship_shipments_attributes: [:carrier,
                                                                   :track_no,
                                                                   :boxes,
                                                                   :id,
                                                                   :_destroy,
                                                                   :dispatched_at,
                                                                   sponsorship_swag_ids: []] )
  end
end
