module Private
  class CommentsController < BaseController

    def create
      comment = ticket.comments.new(comment_params.merge(author_id: current_user.id))

      if comment.save
        flash[:notice] = "Comment successfully" #TODO i18n
      else
        flash[:alert] = "Something went wrong" #TODO i18n
      end
      redirect_to ticket_path(ticket)
    end

    private

    def comment_params
      params.required(:comment).permit(:content)
    end

    def ticket
      @ticket ||= current_user.tickets.find(params[:ticket_id])
    end

  end
end
