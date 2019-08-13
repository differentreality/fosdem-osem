# frozen_string_literal: true

class Sponsor < ApplicationRecord
  has_many :sponsorships

  has_paper_trail

  mount_uploader :picture, PictureUploader, mount_on: :logo_file_name

  validates :name, presence: true
end
