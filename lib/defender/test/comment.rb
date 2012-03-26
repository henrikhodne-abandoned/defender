require 'active_model'

# Stuff to test Defender. You probably shouldn't use this in your application,
# but it is included as an example of the minimum needed for a valid setup.
module Defender::Test
  # A fake Comment class to use. No need to require ActiveRecord and set up an
  # actual database. We will use ActiveModel for callbacks though.
  class Comment
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks
    define_model_callbacks :save
    define_model_callbacks :create

    # We now have a "valid" model, let's bring in Defender.
    include Defender::Spammable

    attr_accessor :body, :author, :author_ip, :created_at, :spam, :defensio_sig

    # Returns true if save has been called, false otherwise.
    def new_record?
      !(@saved ||= false)
    end

    # Run save callback and make {Defender::Test::Comment.new_record?} return false.
    #
    # The with_callbacks method is only for using this as a test interface.
    def save(with_callbacks=true)
      if with_callbacks
        _run_save_callbacks do
          # We're not actually saving anything, just letting Defender know we
          # would be.
          unless defined?(@saved) && @saved
            _run_create_callbacks do
              @saved = true
            end
          end
        end
      else
        @saved = true
      end
    end

    def update_attribute(name, value)
      self.send("#{name}=".to_sym, value)
      self.save
    end
  end
end
