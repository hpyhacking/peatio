module Admin
  class TicketsController < BaseController

    def index
      @tickets = Ticket.order("created_at DESC")
      @tickets = params[:closed].nil? ? @tickets.open : @tickets.closed
    end

    def show
      @comments = ticket.comments
      @comments.unread_by(current_user).each do |c|
        c.mark_as_read! for: current_user
      end
      @comment = Comment.new
      ticket.mark_as_read!(for: current_user) if ticket.unread?(current_user)
    end

    def close
      flash[:notice] = I18n.t('private.tickets.close_succ') if ticket.close!
      redirect_to admin_tickets_path
    end

    protected

    def ticket
      @ticket ||= Ticket.find(params[:id])
    end

  end

end
