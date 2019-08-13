# frozen_string_literal: true

class SponsorSwag < ApplicationRecord
  belongs_to :sponsorship
  has_and_belongs_to_many :sponsor_shipments

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :name, :quantity, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  ##
  # Checks if all swag shipments has been delivered by courier
  # ==== Returns
  # * +True+ -> if all swag shipments have been delivered
  # * +False+ -> if not all swag shipments have been delivered
  def delivered?
    sponsor_shipments.all?(:delivered)
  end

  ##
  # Checks if all swag shipments have arrived at the venue
  # ==== Returns
  # * +True+ -> if all swag is at the venue
  # * +False+ -> if not all swag is at the venue
  def at_venue?
    sponsor_shipments.all?(:available)
  end

  private

  def conference_id
    sponsor.conference_id
  end
end
