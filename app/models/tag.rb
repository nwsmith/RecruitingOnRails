class Tag < ApplicationRecord
  include Trackable

  has_many :candidate_tags, dependent: :destroy
  has_many :candidates, through: :candidate_tags

  validates :name, presence: true, uniqueness: true

  scope :alphabetical, -> { order(:name) }

  # Default chip color when none is set — Pico's primary accent.
  def chip_color
    color.presence || "#1095c1"
  end
end
