require 'wuclan/twitter/model' ; include Wuclan::Twitter::Model
TW_OBJ = '/data/sn/tw/fixd/objects'
TW_OBJ_PATHS = {
  :a_follows_b            => File.join(TW_OBJ, 'a_follows_b'),
  :a_favorites_b          => File.join(TW_OBJ, 'a_favorites_b'),
  :a_replies_b            => File.join(TW_OBJ, 'a_replies_b' ),
  :a_retweets_b           => File.join(TW_OBJ, 'a_retweets_b' ),
  :a_retweets_b_name      => File.join(TW_OBJ, 'a_retweets_b_name' ),
  :a_atsigns_b_name       => File.join(TW_OBJ, 'a_atsigns_b_name' ),
  :tweet                  => File.join(TW_OBJ, 'tweet' ),
  :delete_tweet           => File.join(TW_OBJ, 'delete_tweet' ),
  :twitter_user_search_id => File.join(TW_OBJ, 'twitter_user_search_id' ),
  :twitter_user           => File.join(TW_OBJ, 'twitter_user' ),
  :twitter_user_partial   => File.join(TW_OBJ, 'twitter_user_partial' ),
  :twitter_user_profile   => File.join(TW_OBJ, 'twitter_user_profile' ),
  :twitter_user_style     => File.join(TW_OBJ, 'twitter_user_style' ),
  :twitter_user_id        => File.join(TW_OBJ, 'twitter_user_id' ),
  :twitter_user_location  => File.join(TW_OBJ, 'twitter_user_location' ),
  :hashtag                => File.join(TW_OBJ, 'hashtag' ),
  :smiley                 => File.join(TW_OBJ, 'smiley' ),
  :tweet_url              => File.join(TW_OBJ, 'tweet_url' ),
  :stock_token            => File.join(TW_OBJ, 'stock_token' ),
  :word_token             => File.join(TW_OBJ, 'word_token' ),
  :geo                    => File.join(TW_OBJ, 'geo' )
}
