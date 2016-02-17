# ActsAsBookable

[![Gem Version](https://badge.fury.io/rb/acts_as_bookable.svg)](http://badge.fury.io/rb/acts_as_bookable)
[![Build Status](https://secure.travis-ci.org/tandusrl/acts_as_bookable.png)](http://travis-ci.org/tandusrl/acts_as_bookable)
[![Code Climate](https://codeclimate.com/github/tandusrl/acts_as_bookable.png)](https://codeclimate.com/github/tandusrl/acts_as_bookable)
[![Inline docs](http://inch-ci.org/github/tandusrl/acts_as_bookable.png)](http://inch-ci.org/github/tandusrl/acts_as_bookable)

ActsAsBookable allows resources to be booked by users. It:

* Is a MVC solution based on Rails engines
* Is designed to cover many use cases (hotels bookings, restaurant reservations, shows...)
* Allows to define bookable availabilities with recurring times and exceptions (based on ice_cube)

## Getting started

### Installation

#### Include the gem

ActsAsBookable works with ActiveRecord 3.2 onwards. You can add it to your Gemfile with:

```ruby
gem acts_as_bookable
```

run `bundle install` to install it.

#### Install and run migrations

```bash
bundle exec rake acts_as_bookable:install:migrations
bundle exec rake db:migrate
```

### Bookables, Bookers and Bookings

To set-up a **Bookable** model, use `acts_as_bookable`. A Bookable model is enabled to accept bookings.

```ruby
class Room < ActiveRecord::Base
  acts_as_bookable
end
```

To set-up a **Booker** model, use `acts_as_booker`. Only Bookers can create bookings.

```ruby
class User < ActiveRecord::Base
  acts_as_booker
end
```

From this time on, a User can book a Room with

```ruby
@user.book! @room
```

Or a Room can accept a booking from a User with

```ruby
@room.be_booked! @user
```

The functions above perform the same operation: they create and save a new **Booking**  that has relations with the **Booker** and the **Bookable**.

Since only **Bookers** can book **Bookables**, you must configure both the models. You can even have two or more models configured as **Bookable**, as well as two or more models configured as **Booker**.

You can access bookings both from the Bookable and the Booker

```ruby
@room.bookings # return all bookings created on this room
@user.bookings # return all bookings made by this user
```

## Configuring ActsAsBookable options

There are a number available options to make your models behave differently. They are all configurable in the Bookable model, passing a hash to `acts_as_bookable`

Available options (with values) are:

* `:time_type`: Specifies how the Bookable must be booked in terms of time. Allowed values are:
  * `:none`
  * `:fixed`
  * `:range`
* `:capacity_type`: Specifies how the `amount` of a booking (e.g. number of people of a restaurant reservation) affects the future availability of the bookable. Allowed values are:
  * `:none`
  * `:open`
  * `:closed`
* `:bookable_across_occurrences`: Allows or denies the possibility to book across different occurrences of the availability schedule of the bookable (further explanation below)

> WARNING - Some of the options above need migrations. They are explained in the sections below

### No constraints

The model accepts booking without any constraint. This means every booker can create an infinite number of bookings on it and no capacity or time checks are performed.

Creating a booking on this model means booking it forever and without care for other existing bookings. In other words, the time and the number of bookings do not affect the availability of this bookable. (e.g. pre-ordering a product that will be released soon)

**Configuration**

```ruby
class Product < ActiveRecord::Base
  acts_as_bookable
end
```

**Creating a new bookable**

```ruby
# Creating a new bookable without constraints does not require any additional attribute
@product = Product.create!(...)
```

**Booking**

```ruby
# Booking a model without constraints does not require any additional option
@user.book! @product
```

### Time constraints

The option `time_type` may be used to set a constraint over the booking time.

#### No time constraints - `time_type: :none`

The model is bookable without time constraints.


```ruby
class Product < ActiveRecord::Base
  # As `time_type: :none` is a default, you can omit it. It's shown here for explanation purposes
  acts_as_bookable time_type: :none
end
```

#### Fixed time constraint - `time_type: :fixed`

> WARNING - **migration needed!** - with this option the model must have an attribute `schedule: :text`

The model accepts bookings that specify a fixed `:time`, and the availability is affected only for that time. (e.g. a show in a movie theater)

**Configuration**

```ruby
class Show < ActiveRecord::Base
  acts_as_bookable time_type: :fixed
end
```

**Creating a new bookable**

Each instance of the model must define its availability in terms of time with an [IceCube Schedule](https://github.com/seejohnrun/ice_cube)

```ruby
@show = Show.new(...)
@show.schedule = IceCube::Schedule.new
# This show is available every day at 6PM and 10PM
@show.schedule.add_recurrence_rule IceCube::Rule.daily.hour_of_day(18,22)
@show.save!
```

**Booking**

```ruby
time_ok = Date.today + 18.hours # Today at 6PM
time_wrong = Date.today + 19.hours # Today at 7PM
# Booking a model with `time_type: :fixed` requires a `:time` option
@user1.book! @show, time: time_ok # OK
@user2.book! @show, time: time_wrong # raise ActsAsBookable::AvailabilityError
```

#### Time range constraint - `time_type: :range`

> WARNING - **migration needed!** - with this option the model must have an attribute `schedule: :text`

The model accepts bookings that specify a `:time_start` and a `:time_end`. After a booking is created, the bookable availability is affected only within that range. (e.g. a meeting room)

**Configuration**

```ruby
class MeetingRoom < ActiveRecord::Base
  acts_as_bookable time_type: :range
end
```

**Creating a new bookable**

Each instance of the model must define its availability in terms of time with an [IceCube Schedule](https://github.com/seejohnrun/ice_cube). Although it's not strictly required, it's strongly suggested to create a schedule with a `:duration`, unless you know exactly what you are doing.

```ruby
@meeting_room = MeetingRoom.new(...)
# The schedule starts now and each occurrence is 10 hours long
@meeting_room.schedule = IceCube::Schedule.new(Time.now, duration: 10.hours)
# This meeting_room is available on Mondays starting from 8 AM
@meeting_room.schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday).hour_of_day(8)
@meeting_room.save!
```

**Booking**

```ruby
# Next Monday from 9AM to 11AM
from_ok = Date.today.next_week + 9.hours
to_ok = from_ok + 2.hours
# Next Tuesday from 9AM to 11AM
from_wrong = Date.today.next_week + 1.day + 9.hours
to_wrong = from_wrong + 2.hours

# Booking a model with `time_type: :range` requires `:time_start` and `:time_end`
@user1.book! @meeting_room, time_start: from_ok, time_end: to_ok # OK
@user2.book! @meeting_room, time_start: from_wrong, time_end: to_wrong # raise ActsAsBookable::AvailabilityError
```

### Bookability across occurrences

Combined with `time_type: :range`, the option `bookable_across_occurrences` allows for creating bookings that start in an occurrence of the schedule and end in another occurrence. By default, it's set to `false`.

Let's use two examples to better explain the difference

#### Not bookable across occurrences **`bookable_across_occurrences: false`**

The model accepts only bookings that start and end within the same occurrence (e.g. a meeting room)

**Configuration**

```ruby
class MeetingRoom < ActiveRecord::Base
  # bookable_across_occurrences is always combined with time_type: :range
  # As `bookable_across_occurrences: false` is a default, you can omit it. It's shown here for explanation purposes
  acts_as_bookable time_type: :range, bookable_across_occurrences: false
end
```

**Creating a new bookable**

```ruby
@meeting_room = MeetingRoom.new(...)
# The schedule starts now and each occurrence is 4 hours long
@meeting_room.schedule = IceCube::Schedule.new(Time.now, duration: 4.hours)
# This meeting_room is available everyday, from 9AM to 13AM and from 2PM to 6PM
@meeting_room.schedule.add_recurrence_rule IceCube::Rule.daily.hour_of_day(9,14)
@meeting_room.save!
```

**Booking**

```ruby
# Next Monday from 9AM to 11AM
from_ok = Date.today.next_week + 9.hours
to_ok = from_ok + 2.hours

# Next Monday from 11AM to 6PM
from_wrong = Date.today.next_week + 11.hours
to_wrong = Date.today.next_week + 18.hours

# OK - time_start and time_end belong to the same occurrence
@user1.book! @meeting_room, time_start: from_ok, time_end: to_ok

# raise ActsAsBookable::AvailabilityError - both time_start and time_end are inside the schedule, but they belong to different occurrences
@user2.book! @meeting_room, time_start: from_wrong, time_end: to_wrong
```

#### Bookable across occurrences **`bookable_across_occurrences: true`**

The model may accept bookings that start and end in different occurrences (e.g. a hotel room)

**Configuration**

```ruby
class Room < ActiveRecord::Base
  # bookable_across_occurrences is always combined with time_type: :range
  acts_as_bookable time_type: :range, bookable_across_occurrences: true
end
```

**Creating a new bookable**

```ruby
@room = Room.new(...)
# The schedule starts today and each occurrence is 1 day long
@room.schedule = IceCube::Schedule.new(Date.today, duration: 1.day)
# This room is available every week, on weekends
@room.schedule.add_recurrence_rule IceCube::Rule.weekly.day(:friday,:saturday,:sunday)
@room.save!
```

**Booking**

```ruby
# check-in Friday, check-out Sunday
check_in_ok = Date.today.next_week + 4.days
check_out_ok = check_in_ok + 2.days

# check-in Tuesday, check-out Sunday
check_in_wrong = Date.today.next_week + 4.days
check_out_wrong = check_in_wrong + 3.days

# OK - time_start and time_end belong to different occurrences
@user1.book! @room, time_start: check_in_ok, time_end: check_out_ok

# raise ActsAsBookable::AvailabilityError - while time_end belongs to an occurrence, time_begin doesn't belong to any occurrence of the schedule
@user2.book! @room, time_start: check_in_wrong, time_end: check_out_wrong
```

### Capacity constraints

The option `capacity_type` may be used to set a constraint over the `amount` attribute of the booking

#### No capacity constraints - `capacity_type: :none`

The model is bookable without capacity constraints.

```ruby
class Product < ActiveRecord::Base
  # As `capacity_type: :none` is a default, you can omit it. It's shown here for explanation purposes
  acts_as_bookable capacity_type: :none
end
```

#### Open capacity - `capacity_type: :open`

> WARNING - **migration needed!** - with this option the model must have an attribute `capacity: :integer`

The model is bookable until its `capacity` is reached. (e.g. an event)

**Configuration**

```ruby
class Event < ActiveRecord::Base
  acts_as_bookable capacity_type: :open
end
```

**Creating a new bookable**

Each instance of the model must define its capacity.

```ruby
@event = Event.new(...)
@event.capacity = 30 # This event accepts 30 people
@event.save!
```

**Booking**

```ruby
# Booking a model with `capacity_type: :open` requires `:amount`
@user1.book! @event, amount: 5 # booking the event for 5 people, OK
@user2.book! @event, amount: 20 # booking the event for other 20 people, OK
@user3.book! @event, amount: 10 # overbooking! raise ActsAsBookable::AvailabilityError
```

#### Closed capacity - `capacity_type: :closed`

> WARNING - **migration needed!** - with this option the model must have an attribute `capacity: :integer`

Similar to open capacity, but after the model is booked, it's no more available, no matter if capacity has not been reached. (e.g. a private room)

**Configuration**

```ruby
class PrivateRoom < ActiveRecord::Base
  acts_as_bookable capacity_type: :closed
end
```

**Creating a new bookable**

Each instance of the model must define its capacity.

```ruby
@private_room = PrivateRoom.new(...)
@private_room.capacity = 30 # This private_room accepts 30 people
@private_room.save!
```

**Booking**

```ruby
# Booking a model with `capacity_type: :closed` requires `:amount`
@user1.book! @private_room, amount: 35 # overbooking! raise ActsAsBookable::AvailabilityError
@user2.book! @private_room, amount: 5 # booking for 5 people, OK
@user3.book! @private_room, amount: 5 # not available! Although the room can still hosts (potentially) 25 people, it has already been booked. raise ActsAsBookable::AvailabilityError

```

### Mixing options

All the options may be mixed together to achieve different goals.

Adding an option means adding a constraint to the effectiveness of a booking on a bookable.

### Presets

Some combinations of common options are provided as built-in presets. They are activated using just the option `:preset`

As for now only these presets are provided, others are coming soon:

* `:room`

#### Room - `preset: :room`

> WARNING - **migration needed!** - with this option the model must have an attribute `capacity: :integer` and an attribute `schedule: :text`

An hotel room has the following costraints:

1. It accepts bookings that specify a **range of time** (i.e. check-in and check-out)
2. It has a **capacity** that cannot be exceeded
3. After it has been booked, it becomes unavailable for the given range of time, even though its capacity has not been reached.
4. Its availability is expressed in terms of opening days (a schedule of 1 day long occurrences), but a single booking may cover more than one day (e.g. a weekend)

**Configuration**:

```ruby
class Room < ActiveRecord::Base
  acts_as_bookable preset: :room
end
```

Which is equivalent to

```ruby
class Room < ActiveRecord::Base
  acts_as_bookable  time_type: :range,
                    capacity_type: :closed,
                    bookable_across_occurrences: true
end
```


**Booking:**

```ruby
# A @user books a @room for 2 people. Check-in is today and check-out is tomorrow.
@user.book! @room, time_start: Date.today, time_end: Date.tomorrow, amount: 2
```

## FYI

### Hey... Why not just an initializer?

We decided not to provide an initializer to configure bookings because one of the goals of this gem is to allow for different kinds of booking inside the same application.

This is achieved delegating the responsability of deciding "how a booking should be created" to the Bookable itself. In this way, different configurations of `acts_as_bookable` inside a model bring to different ways of creating and managing bookings for ***that*** *(and only that)* model.

### License

Copyright 2016 Tandù srl

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Acknowledgements

To speed-up the initialization process of this project, the structure of this repository was strongly influenced by [ActsAsTaggableOn](https://github.com/mbleigh/acts-as-taggable-on) by Michael Bleigh and Intridea Inc.
