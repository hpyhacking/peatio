module Admin
  class CommentsController < BaseController

    def create
      comment = ticket.comments.new(comment_params.merge(author_id: current_user.id))

      if comment.save
        flash[:notice] = I18n.t("private.tickets.comment_succ")
      else
        flash[:alert] = I18n.t("private.tickets.comment_fail")
      end
      redirect_to admin_ticket_path(ticket)
    end


    protected

    def comment_params
      params.required(:comment).permit(:content)
    end

    def ticket
      @ticket ||= Ticket.find(params[:ticket_id])
    end

  end
end
