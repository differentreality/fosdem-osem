# frozen_string_literal: true

class Sponsor < ApplicationRecord
  include ActiveRecord::Transitions
  belongs_to :sponsorship_level
  belongs_to :conference

  has_many :sponsor_swags
  has_many :sponsor_shipments

  accepts_nested_attributes_for :sponsor_swags, allow_destroy: true
  accepts_nested_attributes_for :sponsor_shipments, allow_destroy: true

  has_paper_trail ignore: [:updated_at], meta: { conference_id: :conference_id }

  mount_uploader :picture, PictureUploader, mount_on: :logo_file_name

  validates :name, presence: true

  scope :confirmed, -> { where(state: 'confirmed') }
  scope :unconfirmed, -> { where('state = ? OR state = ? OR state = ?', 'unconfirmed', 'contacted', 'not_started') }
  scope :contacted, -> { where(state: 'contacted') }
  scope :to_contact, -> { where(state: 'not_started') }

  def self.pending
    where('state = ? OR state = ? OR state = ?', 'unconfirmed', 'contacted', 'not_started')
  end

  def self.with_shipment
    select{ |sponsor| sponsor.sponsor_shipments.any? }
  end

  def self.with_swag
    select{ |sponsor| sponsor.sponsor_swags.any? }
  end

  state_machine initial: :not_started do
   state :not_started
   state :contacted
   state :unconfirmed
   state :confirmed
   state :cancelled

   event :contacted do
     transitions to: :contacted, from: [:not_started]
   end

   event :unconfirmed do
     transitions to: :unconfirmed, from: [:contacted, :confirmed, :not_started]
   end

   event :confirm do
     transitions to: :confirmed, from: [:unconfirmed, :contacted, :not_started]
   end

   event :cancel do
     transitions to: :cancelled, from: [:confirmed, :unconfirmed, :contacted]
   end

   event :restart do
     transitions to: :not_started, from: [:cancelled, :contacted]
   end
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(current_state).include?(transition)
  end
end
