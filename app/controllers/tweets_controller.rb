class TweetsController < ApplicationController
  before_action :authenticate_user!, only: %i(create)
  before_action :set_tweets, only: %i(create)

  def create
    if params[:tweet][:text].present?
      @tweet = Tweet.new(tweet_params)
      @photo = Photo.recent(current_user)
      @photo_uri = set_uri(@photo.photo.blob.key)
      @set_tweet = set_text(@tweet.text, @tweet.hushtag)
      @result = AnriTwitter.new(@set_tweet.to_s, @photo_uri.to_s).tweet
      set_tweet(@tweet, @result, current_user, @photo)
      if @tweet.save
        render 'components/posts/posts_index', local: { tweet: @tweet, photo_uri: @photo_uri }
      else
        render 'components/posts/posts_error'
      end
    else
      render 'components/posts/posts_error'
    end
  end

  def show
  end

  private

  def set_tweets
    @tweet = Tweet.find(params[:id])
  end

  def tweet_params
    params.require(:tweet).permit(:text, :hushtag)
  end
end
