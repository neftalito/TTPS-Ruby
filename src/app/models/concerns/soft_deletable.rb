# frozen_string_literal: true

module SoftDeletable
  extend ActiveSupport::Concern

  included do
    include Discard::Model

    self.discard_column = :deleted_at

    default_scope -> { kept }
    scope :with_deleted, -> { with_discarded }
    scope :only_deleted, -> { discarded }
  end

  def destroy
    return false if discarded?

    result = run_callbacks(:destroy) { discard }
    @destroyed = true if result
    result
  end

  def destroy!
    destroy || raise(ActiveRecord::RecordNotDestroyed)
  end

  def delete
    destroy
  end

  def restore
    undiscard.tap do |restored|
      @destroyed = false if restored
    end
  end

  def deleted?
    discarded?
  end

  module ClassMethods
    def delete_all
      update_all(discard_column => Time.current)
    end

    alias destroy_all delete_all
  end
end