# JsonapiRspec

[![Gem Version](https://badge.fury.io/rb/jsonapi_rspec.svg)](https://badge.fury.io/rb/jsonapi_rspec)
[![Build Status](https://travis-ci.org/midwire/jsonapi_rspec.svg?branch=master)](https://travis-ci.org/midwire/jsonapi_rspec)

Match json:api formatted Rack::Response (or Rails controller response) to an instantiated object or ActiveRecord/ActiveModel object.

This project started because I wanted to be able to easily compare a json:api response to a model in my Rails API controllers, across several projects. Finding myself copying the code between projects, I decided to put it all in a gem.

As such, it may not strictly suit your needs, but if you let me know I'll do my best to accommodate, and [pull requests](https://github.com/midwire/jsonapi_rspec/pulls) are always welcome.

## Installation

Add this line to your application's Gemfile:

```ruby
group :test do
  gem 'jsonapi_rspec'
end
```

And then execute:

    $ bundle

## Usage

In your controller specs:

```ruby
my_model = MyModel.create(...)
get :show, params: { id: my_model.id }
expect(response).to be_jsonapi_response_for(my_model)
```

It currently tests for compliant json:api sections and matching attributes for the passed model instance.
```
{
  "jsonapi": "version 1.1", // does not check
  "data":{                  // checks if exists and is a hash
    "id":"123",             // checks if this matches the object.id
    "type":"tags",          // checks if exists and is the matching type for object
    "attributes":{          // checks each attr. against object attributes
      "string_attribute":"Category",
      "datetime_attribute":"2017-10-13T19:33:54+00:00",
      "time_attribute":"2017-10-14 17:12:45 -0500",
      "true_attribute":true,
      "false_attribute":false,
      "nil_attribute":null,
      "fixnum_attribute":11,
      "float_attribute":11.11,
      "bignum_attribute":9999999999999999999999999999999,
      "links":{             // does not check
        "self":"http://test.host/api/v1/tag_types.123"
      }
    }
  },
  "included": [{            // does not check
    "type": "users",
    "id": 9,
    "attributes": {
      "first-name": "Dan",
      "last-name": "Gebhardt",
      "twitter": "dgeb"
    },
    "links": {
      "self": "http://example.com/users/9"
    }
  }],
  "meta":{                  // checks are configurable
    "copyright":"Copyright 2017 Chris Blackburn",
    "version":"v1"
  }
}
```

### Checks

* Empty response - `response.empty?`
* Nil response - `response.nil?`
* Error response - catches if the response is an error when expecting a matching object response.
* Missing a required top level section - must include 'data', 'errors' or 'meta'
* Conflicting top level section - 'included' is invalid without a 'data' section
* Unexpected top level key - catches invalid top level keys
* Invalid data section - 'data' section must be an Array (collection) or Hash (single-object)
* Data type mismatch - 'data:type' doesn't match the object type
* Object ID mismatch - 'data:id' doesn't match the object ID
* Missing meta - if configured (see Configuration below) reports missing 'meta' section

### Possible Failure Messages

[See failure_messages.rb](https://github.com/midwire/jsonapi_rspec/blob/develop/lib/jsonapi_rspec/failure_messages.rb).

[See the specs](https://github.com/midwire/jsonapi_rspec/blob/develop/spec/lib/jsonapi_rspec/be_json_api_response_for_spec.rb) for more details.

### Configuration

This is the only configuration option at the moment:

    JsonapiRspec.configure do |config|
      config.meta_required = false # default
    end


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/midwire/jsonapi_rspec.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
