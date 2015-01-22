module Private
  class TicketsController < BaseController
    after_filter :mark_ticket_as_read, only: [:create, :show]

    def index
      @tickets = current_user.tickets
      @tickets = params[:closed].nil? ? @tickets.open : @tickets.closed
      redirect_to new_ticket_path if @tickets.empty?
    end

    def new
      @ticket = Ticket.new
    end

    def create
      @ticket = current_user.tickets.create(ticket_params)
      if @ticket.save
        flash[:notice] = I18n.t('private.tickets.ticket_create_succ')
        redirect_to tickets_path
      else
        flash[:alert] = I18n.t('private.tickets.ticket_create_fail')
        render :new
      end
    end

    def show
      @comments = ticket.comments
      @comments.unread_by(current_user).each do |c|
        c.mark_as_read! for: current_user
      end
      @comment = Comment.new
    end

    def close
      flash[:notice] = I18n.t('private.tickets.close_succ') if ticket.close!
      redirect_to tickets_path
    end

    private

    def ticket_params
      params.required(:ticket).permit(:title, :content)
    end

    def ticket
      @ticket ||= current_user.tickets.find(params[:id])
    end

    def mark_ticket_as_read
      ticket.mark_as_read!(for: current_user) if ticket.unread?(current_user)
    end
  end
end
