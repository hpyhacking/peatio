module Private
  class TicketsController < BaseController
    def index
      @tickets = current_user.tickets.open
    end

    def new
      @ticket = Ticket.new
    end

    def create
      ticket = current_user.tickets.create(ticket_params)
      if ticket.save
        flash[:notice] = I18n.t('private.tickets.ticket_create_succ')
        redirect_to tickets_path
      else
        flash[:alert] = I18n.t('private.tickets.ticket_create_fail')
        render :new
      end
    end

    def show
      @comments = ticket.comments
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
  end
end
