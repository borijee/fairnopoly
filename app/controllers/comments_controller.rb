class CommentsController < ApplicationController

  COMMENTABLES = [Library, Article]

  respond_to :js

  before_filter :set_commentable, only: [:index, :create, :update, :destroy]
  before_filter :set_comment, only: [:update, :destroy]
  skip_before_filter :authenticate_user!, only: [:index]

  def index
    @comment = Comment.new
    @comments = @commentable.comments

    if params[:comments_page]
      @comments = @comments.page(params[:comments_page])
      render partial: "comments/index_paginated", locals: {
        comments: @comments,
        commentable: @commentable
      }
    end
  end

  def create
    comment_data = { user: current_user }.merge(params.for(Comment).refine)
    @comment = @commentable.comments.build(comment_data)
    authorize @comment

    if @comment.save
      # In the view we are using the comments_count counter cache, which is not automatically
      # updated in the object, so we do it by hand.
      # Please don't save this object from now on.
      @commentable.comments_count += 1

      # if save was successful, please create a new comment object to render the input form with
      @new_comment = Comment.new
      render :create
    else
      render :new, comment: @comment, commentable: @commentable
    end
  end

  def destroy
    authorize @comment
    @comment.destroy

    # In the view we are using the comments_count counter cache, which is not automatically
    # updated in the object, so we do it by hand.
    # Please don't save this object from now on.
    @commentable.comments_count -= 1
  end

  private

  def set_commentable
    commentable_key = params.keys.select { |p| p.match(/[a-z_]_id$/) }.last

    # Class can be inferred from the key.
    # We're using the HEARTABLES array for protection though.
    commentable_class = COMMENTABLES.select do |klass|
      klass.to_s.downcase == commentable_key[0..-4]
    end.first

    @commentable = commentable_class.find(params[commentable_key])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end
end
