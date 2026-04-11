class ActivitiesController < ApplicationController
  before_action :check_admin

  PAGE_SIZE = 50

  def index
    @activities = Activity.recent
    @activities = @activities.where(actor_id: params[:actor_id])         if params[:actor_id].present?
    @activities = @activities.where(target_type: params[:target_type])   if params[:target_type].present?
    @activities = @activities.where(candidate_id: params[:candidate_id]) if params[:candidate_id].present?

    # Simple manual pagination — no Kaminari/will_paginate dependency. The
    # admin audit view rarely needs to span multiple pages but the option
    # is there for long-running deployments.
    @page  = (params[:page].presence || 1).to_i.clamp(1, 10_000)
    @total = @activities.count
    @activities = @activities.limit(PAGE_SIZE).offset((@page - 1) * PAGE_SIZE)
  end
end
