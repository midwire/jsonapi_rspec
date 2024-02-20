# frozen_string_literal: true

class String
  # Helper for the heredoc functionality. Allows pipe '|' delimeted heredocs
  # with a parameterized delimeter.
  #
  # Example:
  # html = <<-stop.here_with_pipe(delimeter="\n")
  #   |<!-- Begin: comment  -->
  #   |<script type="text/javascript">
  # stop
  # html == '<!-- Begin: comment  -->\n<script type="text/javascript">'
  #
  # @param [String] delimeter Joins the lines of strings with this delimeter.
  #
  # @return [String] Returns the concatenated string.
  #
  def here_with_pipe!(delimeter = ' ')
    lines = split("\n")
    lines.map! { |c| c.sub!(/\s*\|/, '') }
    new_string = lines.join(delimeter)
    replace(new_string)
  end
end
