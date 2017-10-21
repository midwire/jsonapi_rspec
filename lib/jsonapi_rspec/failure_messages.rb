# Module FailureMessages provides a list of defined failure messages.
#
# @author Chris Blackburn <87a1779b@opayq.com>
#
module FailureMessages
  GENERAL_PREFIX = 'Expected a json:api compliant success response but'.freeze
  OBJECT_PREFIX = 'Expected a json:api response for an object instance but'.freeze

  ERROR = 'it is an error'.freeze
  EMPTY = 'it is empty'.freeze
  NIL   = 'it is nil'.freeze

  MISSING_REQ_TOP_LVL    = 'it is missing a required top-level section'.freeze
  CONFLICTING_TOP_LVL    = "it cannot contain 'included' without a 'data' section".freeze
  UNEXPECTED_TOP_LVL_KEY = "it has an unexpected key: '%s'".freeze
  INVALID_DATA_SECTION   = "the 'data' section must be a Hash or an Array".freeze
  DATA_TYPE_MISMATCH     = "data:type '%s' doesn't match: '%s'".freeze
  OBJECT_ID_MISMATCH     = "data:id '%s' doesn't match object id: '%s'".freeze
  MISSING_META           = "the 'meta' section is missing or invalid".freeze
end
