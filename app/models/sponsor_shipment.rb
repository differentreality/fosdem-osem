# frozen_string_literal: true

class SponsorShipment < ApplicationRecord
  belongs_to :sponsorship
  has_and_belongs_to_many :sponsor_swags

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  validates :carrier, :boxes, presence: true
  validates :track_no, uniqueness: true
  validates :boxes, numericality: { greater_than_or_equal_to: 0 }

  private

  def conference_id
    sponsor.conference_id
  end
end
