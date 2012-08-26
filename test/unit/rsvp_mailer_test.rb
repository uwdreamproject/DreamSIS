require 'test_helper'

class RsvpMailerTest < ActionMailer::TestCase
  test "rsvp" do
    @expected.subject = 'RsvpMailer#rsvp'
    @expected.body    = read_fixture('rsvp')
    @expected.date    = Time.now

    assert_equal @expected.encoded, RsvpMailer.create_rsvp(@expected.date).encoded
  end

  test "cancel" do
    @expected.subject = 'RsvpMailer#cancel'
    @expected.body    = read_fixture('cancel')
    @expected.date    = Time.now

    assert_equal @expected.encoded, RsvpMailer.create_cancel(@expected.date).encoded
  end

  test "reminder" do
    @expected.subject = 'RsvpMailer#reminder'
    @expected.body    = read_fixture('reminder')
    @expected.date    = Time.now

    assert_equal @expected.encoded, RsvpMailer.create_reminder(@expected.date).encoded
  end

end
