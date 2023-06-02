Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root :to => "api#home"

  scope controller: 'api', path: 'api' do
    post 'user/login/' => :user_login
    post 'set/clock_in/' => :set_clock_in
    post 'follow/' => :follow_friend
    delete 'follow/' => :unfollow_friend

    # use post here because of the encode problem
    post 'sleep/record' => :sleep_record

    # get 'api/getTagStory/:tagid', to: 'story_api#getTagStory', :constraints => {:tagid => /\d+/} #need test case
  end

end


=begin

We would like you to implement a “good night” application to let users track when do they go to bed and when do they wake up.
We require some restful APIS to achieve the following:
1. Clock In operation, and return all clocked-in times, ordered by created time.
2. Users can follow and unfollow other users.
3. See the sleep records of a user’s All following users’ sleep records. from the previous week, which are sorted based on the duration of All friends sleep length.
This is a 3rd requirement response example
{
  record 1 from user A,
  record 2 from user B,
  record 3 from user A,
  ...
}
Please implement the model, db migrations, and JSON API.

=end