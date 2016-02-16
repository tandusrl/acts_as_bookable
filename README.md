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

ActsAsBookable works with ActiveRecord 3.2 onwards. You can add it to your Gemfile with:

```ruby
gem acts_as_bookable
```

run `bundle install` to install it.

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

## Configuring booking constraints

There are a number available options to make your models behave differently. They are all configurable in the Bookable model, passing a hash to `acts_as_bookable`

Available options are:

* `:time_type`: Specifies how the Bookable must be booked in terms of time.
* `:capacity_type`: Specifies how the `amount` of a booking (e.g. number of people of a restaurant reservation) affects the future availability of the bookable
* `:bookable_across_occurrences`: Allows or denies the possibility to book across different occurrences of the availability schedule of the bookable (further explanation below)


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

The model is bookable without time constraints. As `time_type: :none` is a default, you can omit it.

```ruby
class Product < ActiveRecord::Base
  acts_as_bookable time_type: :none
end
```

#### Fixed time constraint - `time_type: :fixed`

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
# The schedule starts now and each occurrence is one day long
@meeting_room.schedule = IceCube::Schedule.new(Time.now, duration: 1.day)
# This meeting_room is available on Mondays
@meeting_room.schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday)
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

### Capacity constraints

The option `capacity_type` may be used to set a constraint over the `amount` attribute of the booking

#### No capacity constraints - `capacity_type: :none`

The model is bookable without capacity constraints. As `capacity_type: :none` is a default, you can omit it.

```ruby
class Product < ActiveRecord::Base
  acts_as_bookable capacity_type: :none
end
```

#### Open capacity - `capacity_type: :open`

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

# TODO: explain `bookable_across_occurrences` and *mixing options*

### Presets

Some common options are provided as built-in presets

#### Room

A room accept bookings that specify a range of time (i.e. check-in and check-out), and it's unavailable in that range after it has been booked.

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


Booking:

```ruby
# A @user books a @room for 2 people.
# Check-in is today and check-out is tomorrow.
# :time_start an :time_end must be Date or Time objects
@user.book! @room, time_start: Date.today, time_end: Date.tomorrow, amount: 2
```

## FYI

### Hey... Why not just an initializer?

We decided not to provide an initializer to configure bookings because one of the goals of this gem is to allow for different kinds of booking inside the same application.

This is achieved delegating the responsability of deciding "how a booking should be created" to the Bookable itself. Different configurations of `acts_as_bookable` inside a model bring to different ways of creating and managing bookings for ***that** (and only that)* model.

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
