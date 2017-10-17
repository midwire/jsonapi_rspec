# JsonapiRspec

[![Build Status](https://travis-ci.org/midwire/jsonapi_rspec.svg?branch=master)](https://travis-ci.org/midwire/jsonapi_rspec)

Match json:api formatted Rack::Response (or Rails controller response) to an instantiated object or ActiveRecord/ActiveModel object.

This project started because I wanted to be able to easily compare a json:api response to a model in my Rails API controllers, across several projects. Finding myself copying the code between projects, I decided to stick it all in a gem.

As such, it may not strictly suit your needs, but if you let me know I'll do my best to accommodate.

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

It currently tests for required json:api sections and matching attributes for the passed model instance.
```json
{
  "jsonapi": "version 1.1",   // does not check
  "data":{                    // checks if exists and is a hash
    "id":"123",               // checks if this matches the object.id
    "type":"tags",     // checks if exists and is the matching type for object
    "attributes":{     // checks each attrib. against object attributes
      "string_attribute":"Category",
      "datetime_attribute":"2017-10-13T19:33:54+00:00",
      "time_attribute":"2017-10-14 17:12:45 -0500",
      "true_attribute":true,
      "false_attribute":false,
      "nil_attribute":null,
      "fixnum_attribute":11,
      "float_attribute":11.11,
      "bignum_attribute":9999999999999999999999999999999,
      "links":{                // does not check
        "self":"http://test.host/api/v1/tag_types.123"
      }
    }
  },
  "included": [{               // does not check
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
  "meta":{  // does not check for existance by default
    "copyright":"Copyright 2017 Chris Blackburn", // required if meta tag exists
    "version":"v1"  // required if meta tag exists
  }
}
```

### Possible Failure Messages

* 'Response is an error'
* "Unexpected key in response: '#{key}'"
* 'Expected response to match an object instance but it is an empty string'
* "The 'data' section is missing or invalid"
* "Expected data:type '#{data_type}' to match: '#{object_type}'"
* "The 'meta' section is missing or invalid"
* "The 'meta:version' is missing"
* "The 'meta:copyright' is missing or invalid - regex: '/^Copyright.+\\d{4}/'"
* "Fix 'match_attribute?' method to handle: '#{obj_val_class_name}'" - please file an issue if you get this one.
* "Attribute: :#{attr_name} with a value of '#{json_val}'(#{json_val.class.name}) does not match object: '#{obj_val}'(#{obj_val.class.name})
* "Expected '#{value}' to match object id: '#{object_id}'"

See the specs for details.

### Configuration

This is the only configuration option at the moment:

    JsonapiRspec.configure do |config|
      config.meta_required = false # default
    end


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/midwire/jsonapi_rspec.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
