module Admin
  class TicketsController < BaseController
    def index
      @tickets = Ticket.order("created_at DESC")
      @tickets = params[:closed].nil? ? @tickets.open : @tickets.closed
    end

    def show
      @ticket = Ticket.find(params[:id])
      @comments = @ticket.comments
      @comment = Comment.new
    end

  end

end
