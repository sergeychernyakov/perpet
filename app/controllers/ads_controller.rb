class AdsController < ApplicationController
  def index
    @kind = params[:kind].presence || Ad::ALL_KINDS
    @query = params[:q].to_s.strip

    scope = Ad.published.of_kind(@kind).search(@query).recent
    @total = Ad.published.count
    @pager = Paginator.new(scope, page: params[:page])
    @ads = @pager.records
  end
end
