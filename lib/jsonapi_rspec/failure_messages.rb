# frozen_string_literal: true

# Module FailureMessages provides a list of defined failure messages.
#
# @author Chris Blackburn <87a1779b@opayq.com>
#
module FailureMessages
  GENERAL_PREFIX = 'Expected a json:api compliant success response but'
  OBJECT_PREFIX = 'Expected a json:api response for an object instance but'

  ERROR = 'it is an error'
  EMPTY = 'it is empty'
  NIL   = 'it is nil'

  MISSING_REQ_TOP_LVL    = 'it is missing a required top-level section'
  CONFLICTING_TOP_LVL    = "it cannot contain 'included' without a 'data' section"
  UNEXPECTED_TOP_LVL_KEY = "it has an unexpected key: '%s'"
  INVALID_DATA_SECTION   = "the 'data' section must be a Hash or an Array"
  DATA_TYPE_MISMATCH     = "data:type '%s' doesn't match: '%s'"
  OBJECT_ID_MISMATCH     = "data:id '%s' doesn't match object id: '%s'"
  MISSING_META           = "the 'meta' section is missing or invalid"
end
